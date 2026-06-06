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
    @Published var selectedStatusFilter: UserAnimeStatus? = nil
    @Published var selectedSortOption: FavoriteSortOption = .addedAt
    
    private let userDataProvider: UserDataProvider
    private let animeDataFetcher: AnimeDataFetcher
    @Published var animeStatusDict: [Int: (isFavorite: Bool, isNotify: Bool)] = [:]
    var animeTimeDict: [Int: (addedAt: Date, updatedAt: Date, userStatus: UserAnimeStatus)] = [:]
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        userDataProvider: UserDataProvider = LocalRecordManager.shared,
        animeDataFetcher: AnimeDataFetcher = AnimeDataFetcher.shared
    ) {
        self.userDataProvider = userDataProvider
        self.animeDataFetcher = animeDataFetcher
        
        print("### init")
        
        // Trigger reload when filter or sort option changes
        Publishers.CombineLatest($selectedStatusFilter, $selectedSortOption)
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                self?.shouldReloadData.send(())
            }
            .store(in: &cancellables)

        // Trigger for both reload and load more
        let fetchTrigger = shouldReloadData
            .handleEvents(receiveOutput: { [weak self] _ in
                userDataProvider.resetFavoritePagination()
            })
            .map { true } // isReload
            .merge(with: shouldLoadMoreData.map { false }) // isReload = false
            .filter { [weak self] isReload in
                if isReload {
                    return true // Always allow reloads/filter changes
                } else {
                    return !(self?.animeDataFetcher.isFetchingData ?? false)
                }
            }
            .share()

        let favoriteAnimePublisher = fetchTrigger
            .map { [weak self] isReload -> AnyPublisher<(Bool, [Response.LocalAnimeRecord]), Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "FavoriteViewViewModel", code: -1)).eraseToAnyPublisher()
                }
                return self.userDataProvider.loadUserFavorite(
                    perFetch: 10,
                    userStatus: self.selectedStatusFilter,
                    sortBy: self.selectedSortOption
                )
                .map { (isReload, $0) }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
            .share()

        // Update status and time dictionaries
        favoriteAnimePublisher
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _, records in
                records.forEach { record in
                    self?.animeStatusDict.updateValue((record.isFavorite, record.isNotify), forKey: record.id)
                    self?.animeTimeDict.updateValue((record.addedAt, record.updatedAt, record.userStatus), forKey: record.id)
                }
            })
            .store(in: &cancellables)

        // Fetch Anilist data and update favorites list
        favoriteAnimePublisher
            .map { [weak self] isReload, records -> AnyPublisher<(Bool, [Response.AnimeEssentialData]), Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "FavoriteViewViewModel", code: -1)).eraseToAnyPublisher()
                }
                let ids = records.compactMap { Int($0.id) }
                guard !ids.isEmpty else {
                    return Just((isReload, []))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.animeDataFetcher.fetchAnimeSimpleDataByIDs(id: ids)
                    .map { (isReload, $0) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] isReload, animeDatas in
                guard let self = self else { return }
                
                var merged = self.favorites
                if isReload {
                    merged = animeDatas
                } else {
                    let existingIds = Set(merged.map { $0.id })
                    let newAnimes = animeDatas.filter { !existingIds.contains($0.id) }
                    merged.append(contentsOf: newAnimes)
                }
                
                // Sort in memory
                switch self.selectedSortOption {
                case .addedAt:
                    merged.sort { a, b in
                        let timeA = self.animeTimeDict[a.id]?.addedAt ?? Date.distantPast
                        let timeB = self.animeTimeDict[b.id]?.addedAt ?? Date.distantPast
                        return timeA > timeB
                    }
                case .updatedAt:
                    merged.sort { a, b in
                        let timeA = self.animeTimeDict[a.id]?.updatedAt ?? Date.distantPast
                        let timeB = self.animeTimeDict[b.id]?.updatedAt ?? Date.distantPast
                        return timeA > timeB
                    }
                case .score:
                    merged.sort { a, b in
                        let scoreA = a.averageScore ?? 0
                        let scoreB = b.averageScore ?? 0
                        return scoreA > scoreB
                    }
                case .alphabetical:
                    merged.sort { a, b in
                        let titleA = a.title.english ?? a.title.romaji ?? a.title.native ?? ""
                        let titleB = b.title.english ?? b.title.romaji ?? b.title.native ?? ""
                        return titleA.localizedStandardCompare(titleB) == .orderedAscending
                    }
                }
                
                self.favorites = merged
            })
            .store(in: &cancellables)
        
        shouldConfigAnimeNotification
            .handleEvents(receiveOutput: { [weak self] animeId in
                self?.animeStatusDict[animeId]?.isNotify.toggle()
            })
            .compactMap { [weak self] animeId -> (animeId: Int, isFavorite: Bool, isNotify: Bool)? in
                guard let isFavorite = self?.animeStatusDict[animeId]?.isFavorite,
                      let isNotify = self?.animeStatusDict[animeId]?.isNotify
                else {
                    return nil
                }
                
                return (animeId, isFavorite, isNotify)
            }
            .flatMap { [weak self] parameter -> AnyPublisher<Response.LocalAnimeRecord, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "FavoriteViewViewModel", code: -1, userInfo: nil))
                        .eraseToAnyPublisher()
                }
                let (animeId, isFavorite, isNotify) = parameter
                return self.userDataProvider.updateAnimeRecord(animeID: animeId, isFavorite: isFavorite, isNotify: isNotify, status: Response.AnimeStatus.airing.rawValue)
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
    
    func updateUserStatus(animeID: Int, newStatus: UserAnimeStatus) {
        guard let currentPref = animeStatusDict[animeID] else { return }
        _ = userDataProvider.updateAnimeRecord(
            animeID: animeID,
            isFavorite: currentPref.isFavorite,
            isNotify: currentPref.isNotify,
            status: Response.AnimeStatus.airing.rawValue,
            userStatus: newStatus
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] record in
            self?.shouldReloadData.send(())
        })
        .store(in: &cancellables)
    }

    func toggleFavorite(animeID: Int) {
        guard let currentPref = animeStatusDict[animeID] else { return }
        let nextFavorite = !currentPref.isFavorite
        
        animeStatusDict[animeID]?.isFavorite = nextFavorite
        
        _ = userDataProvider.updateAnimeRecord(
            animeID: animeID,
            isFavorite: nextFavorite,
            isNotify: currentPref.isNotify,
            status: Response.AnimeStatus.airing.rawValue,
            userStatus: nextFavorite ? (animeTimeDict[animeID]?.userStatus ?? .planToWatch) : nil
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] record in
            self?.shouldReloadData.send(())
        })
        .store(in: &cancellables)
    }
}
