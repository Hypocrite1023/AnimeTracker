//
//  TrandingPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/16.
//

import Foundation
import Combine
import UIKit

class TrendingPageViewModel {
    
    
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
    private var cancellables: Set<AnyCancellable> = []
    
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
                        break
                }
            } receiveValue: { trendingData in
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeTrendingData = trendingData
            }
            .store(in: &cancellables)
    }
    
    private func setupPublisher() {
        
    }
    
    private func setupSubscriber() {
        shouldNavigateToDetailPage = animeCollectionViewCellTap.eraseToAnyPublisher()
        
        shouldLoadMoreTrendingData
            .throttle(for: 0.5, scheduler: RunLoop.main, latest: false)
//            .filter { !AnimeDataFetcher.shared.isFetchingData }
            .sink { _ in
                guard let currentPage = self.animeTrendingData?.data.page.pageInfo.currentPage else {
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
                        break
                }
            } receiveValue: { trendingData in
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeTrendingData = trendingData
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
            } receiveValue: { trendingData in
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeTrendingData?.data.page.media.append(contentsOf: trendingData.data.page.media)
                self.animeTrendingData?.data.page.pageInfo = trendingData.data.page.pageInfo
            }
            .store(in: &cancellables)
    }
    
    func createOrUpdateAnimeRecord() -> AnyPublisher<Void, Error> {
        guard let userUID = FirebaseManager.shared.getCurrentUserUID(), let animeID = currentLongPressCellStatus.animeID, let isFavorite = currentLongPressCellStatus.isFavorite, let isNotify = currentLongPressCellStatus.isNotify, let status = currentLongPressCellStatus.status else {
            return Fail(error: FirebaseAnimeRecordError.dataError)
                .eraseToAnyPublisher()
        }
        
        return FirebaseManager.shared.addAnimeRecord(userUID: userUID, animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
    }
    
    func createLocolNotification() -> AnyPublisher<Void, Error> {
        guard let animeId = currentLongPressCellStatus.animeID else {
            return Fail(error: LocolNotificationError.dataError)
                .eraseToAnyPublisher()
        }
        return Future<Void, Error> { promise in
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

enum FirebaseAnimeRecordError: Error {
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


