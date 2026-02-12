//
//  FavoriteViewViewModel.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2025/10/4.
//

import Foundation
import Combine

class FavoriteViewViewModel: ObservableObject {
    
    let shouldReloadData: PassthroughSubject<Void, Never> = .init()
    let shouldLoadMoreData: PassthroughSubject<Void, Never> = .init()
    let shouldConfigAnimeNotification: PassthroughSubject<Int, Never> = .init()
    
    @Published var favorites: [Response.AnimeEssentialData] = []
    
    private let fireBaseDataProvider: FirebaseDataProvider
    private let animeDataFetcher: AnimeDataFetcher
    @Published var animeStatusDict: [Int: (isFavorite: Bool, isNotify: Bool)] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        fireBaseDataProvider: FirebaseDataProvider = FirebaseManager.shared,
         animeDataFetcher: AnimeDataFetcher = AnimeDataFetcher.shared
    ) {
        self.fireBaseDataProvider = fireBaseDataProvider
        self.animeDataFetcher = animeDataFetcher
        
        print("### init")

        // Trigger for both reload and load more
        let fetchTrigger = shouldReloadData
            .handleEvents(receiveOutput: { [weak self] _ in
                fireBaseDataProvider.resetFavoritePagination()
            })
            .map { true } // isReload
            .merge(with: shouldLoadMoreData.map { false }) // isReload = false
            .filter { [weak self] _ in !(self?.animeDataFetcher.isFetchingData ?? false) }
            .share()

        let favoriteAnimePublisher = fetchTrigger
            .flatMap { isReload in
                fireBaseDataProvider.loadUserFavorite(perFetch: 10)
                    .map { (isReload, $0) }
            }
            .share()

        // Update status dictionary
        favoriteAnimePublisher
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _, records in
                records.forEach { record in
                    self?.animeStatusDict.updateValue((record.isFavorite, record.isNotify), forKey: record.id)
                }
            })
            .store(in: &cancellables)

        // Fetch Anilist data and update favorites list
        favoriteAnimePublisher
            .flatMap { isReload, records -> AnyPublisher<(Bool, [Response.AnimeEssentialData]), Error> in
                let ids = records.compactMap { Int($0.id) }
                guard !ids.isEmpty else {
                    return Just((isReload, []))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return animeDataFetcher.fetchAnimeSimpleDataByIDs(id: ids)
                    .map { (isReload, $0) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] isReload, animeDatas in
                if isReload {
                    self?.favorites = animeDatas
                } else {
                    // Append only new ones
                    let existingIds = Set(self?.favorites.map { $0.id } ?? [])
                    let newAnimes = animeDatas.filter { !existingIds.contains($0.id) }
                    self?.favorites.append(contentsOf: newAnimes)
                }
            })
            .store(in: &cancellables)
        
        shouldConfigAnimeNotification
            .handleEvents(receiveOutput: { [weak self] animeId in
                self?.animeStatusDict[animeId]?.isNotify.toggle()
            })
            .compactMap { [weak self] animeId -> (userUID: String, animeId: Int, isFavorite: Bool, isNotify: Bool)? in
                guard let userUID = fireBaseDataProvider.getCurrentUserUID(),
                      let isFavorite = self?.animeStatusDict[animeId]?.isFavorite,
                      let isNotify = self?.animeStatusDict[animeId]?.isNotify
                else {
                    return nil
                }
                
                return (userUID, animeId, isFavorite, isNotify)
            }
            .flatMap { parameter in
                let (userUID, animeId, isFavorite, isNotify) = parameter
                return fireBaseDataProvider.updateAnimeRecord(userUID: userUID, animeID: animeId, isFavorite: isFavorite, isNotify: isNotify, status: Response.AnimeStatus.airing.rawValue)
            }
            .handleEvents(receiveOutput: { record in
                if !record.isNotify {
                    AnimeNotification.shared.removeAllEpisodeNotification(for: record.id)
                }
            })
            .filter { $0.isNotify }
            .flatMap { record in
                animeDataFetcher.fetchAnimeEpisodeDataByID(id: record.id)
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("finished")
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }, receiveValue: { episodeData in
                if let nextAiringEpisode = episodeData.data.Media.nextAiringEpisode, let episodes = episodeData.data.Media.episodes {
                    AnimeNotification.shared.setupAllEpisodeNotification(animeID: episodeData.data.Media.id, animeTitle: episodeData.data.Media.title.native, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                }
            })
            .store(in: &cancellables)
    }
}
