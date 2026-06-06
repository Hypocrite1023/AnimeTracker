//
//  TrandingPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/16.
//

import Foundation
import Combine
import UIKit

class TrendingPageViewModel: ObservableObject {
    
    // MARK: - input
    let animeCollectionViewCellTap: PassthroughSubject<Int, Never> = .init()
    let shouldLoadMoreTrendingData: PassthroughSubject<Void, Never> = .init()
    let shouldRefreshTrendingData: PassthroughSubject<Void, Never> = .init()
    
    // MARK: - output
    var shouldNavigateToDetailPage: AnyPublisher<Int, Never> = .empty
    
    // MARK: - data property
    var selectedAnimeCell: UICollectionViewCell?
    var currentLongPressCellStatus: (isFavorite: Bool?, isNotify: Bool?, status: String?, animeID: Int?)
    @Published var animeTrendingData: Response.AnimeTrending?
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        setupPublisher()
        setupSubscriber()
        
        AnimeDataFetcher.shared.fetchAnimeByTrending(page: 1)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] trendingData in
                AnimeDataFetcher.shared.isFetchingData = false
                self?.animeTrendingData = trendingData
            }
            .store(in: &cancellables)
    }
    
    private func setupPublisher() {
        
    }
    
    private func setupSubscriber() {
        shouldNavigateToDetailPage = animeCollectionViewCellTap.eraseToAnyPublisher()
        
        shouldLoadMoreTrendingData
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: false)
            .sink { [weak self] _ in
                guard let self = self,
                      let currentPage = self.animeTrendingData?.data.page.pageInfo.currentPage else {
                    return
                }
                print("=========== call load more data")
                self.fetchMoreTrendingAnimeData(currentPage: currentPage + 1)
            }
            .store(in: &self.cancellables)
        
        shouldRefreshTrendingData
            .flatMap { _ in
                AnimeDataFetcher.shared.fetchAnimeByTrending(page: 1)
            }
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] trendingData in
                AnimeDataFetcher.shared.isFetchingData = false
                self?.animeTrendingData = trendingData
            }
            .store(in: &cancellables)
    }
    
    private func fetchMoreTrendingAnimeData(currentPage: Int) {
        AnimeDataFetcher.shared.fetchAnimeByTrending(page: currentPage)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] trendingData in
                guard let self = self else { return }
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeTrendingData?.data.page.media.append(contentsOf: trendingData.data.page.media)
                self.animeTrendingData?.data.page.pageInfo = trendingData.data.page.pageInfo
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Core Data & Notification Helper APIs (SwiftUI Refactored)
    
    func getLocalRecord(for animeID: Int) -> AnyPublisher<Response.LocalAnimeRecord?, Error> {
        return LocalRecordManager.shared.getAnimeRecord(animeID: animeID)
    }
    
    func toggleFavorite(animeID: Int, isNotify: Bool, status: String, currentFavorite: Bool) -> AnyPublisher<Bool, Error> {
        let newFavorite = !currentFavorite
        return LocalRecordManager.shared.addAnimeRecord(animeID: animeID, isFavorite: newFavorite, isNotify: isNotify, status: status)
            .map { newFavorite }
            .eraseToAnyPublisher()
    }
    
    func toggleNotification(animeID: Int, isFavorite: Bool, status: String, currentNotify: Bool) -> AnyPublisher<Bool, Error> {
        let newNotify = !currentNotify
        let updateDb = LocalRecordManager.shared.addAnimeRecord(animeID: animeID, isFavorite: isFavorite, isNotify: newNotify, status: status)
        
        let handleNotification: AnyPublisher<Void, Error>
        if newNotify {
            handleNotification = createLocalNotification(for: animeID)
        } else {
            handleNotification = removeLocalNotification(for: animeID)
        }
        
        return handleNotification
            .flatMap { updateDb }
            .map { newNotify }
            .eraseToAnyPublisher()
    }
    
    private func createLocalNotification(for animeID: Int) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "TrendingPageViewModel", code: -1)))
                return
            }
            AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: animeID)
                .sink { completion in
                    switch completion {
                    case .finished:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } receiveValue: { episodesData in
                    AnimeDataFetcher.shared.isFetchingData = false
                    if let nextAiringEpisode = episodesData.data.Media.nextAiringEpisode, let episodes = episodesData.data.Media.episodes {
                        AnimeNotification.shared.setupAllEpisodeNotification(animeID: animeID, animeTitle: episodesData.data.Media.title.native, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                    }
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    private func removeLocalNotification(for animeID: Int) -> AnyPublisher<Void, Error> {
        AnimeNotification.shared.removeAllEpisodeNotification(for: animeID)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Legacy methods (kept for backward compatibility if needed)
    
    func createOrUpdateAnimeRecord() -> AnyPublisher<Void, Error> {
        guard let animeID = currentLongPressCellStatus.animeID, let isFavorite = currentLongPressCellStatus.isFavorite, let isNotify = currentLongPressCellStatus.isNotify, let status = currentLongPressCellStatus.status else {
            return Fail(error: LocalAnimeRecordError.dataError)
                .eraseToAnyPublisher()
        }
        
        return LocalRecordManager.shared.addAnimeRecord(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
    }
    
    func createLocolNotification() -> AnyPublisher<Void, Error> {
        guard let animeId = currentLongPressCellStatus.animeID else {
            return Fail(error: LocolNotificationError.dataError)
                .eraseToAnyPublisher()
        }
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else { return }
            AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: animeId)
                .sink { completion in
                    switch completion {
                    case .finished:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } receiveValue: { episodesData in
                    AnimeDataFetcher.shared.isFetchingData = false
                    if let nextAiringEpisode = episodesData.data.Media.nextAiringEpisode, let episodes = episodesData.data.Media.episodes {
                        AnimeNotification.shared.setupAllEpisodeNotification(animeID: animeId, animeTitle: episodesData.data.Media.title.native, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                    }
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func removeLocolNotification() -> AnyPublisher<Void, Error> {
        guard let animeId = currentLongPressCellStatus.animeID else {
            return Fail(error: LocolNotificationError.dataError)
                .eraseToAnyPublisher()
        }
        AnimeNotification.shared.removeAllEpisodeNotification(for: animeId)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

enum LocalAnimeRecordError: Error {
    case dataError
    
    var description: String {
        switch self {
        case .dataError:
            return "Data Error"
        }
    }
}

enum LocolNotificationError: Error {
    case dataError
    
    var description: String {
        switch self {
        case .dataError:
            return "Data Error"
        }
    }
}
