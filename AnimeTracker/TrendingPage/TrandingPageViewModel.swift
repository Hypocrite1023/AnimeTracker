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
    @Published var animeTrendingData: AnimeTrending?
    var selectedAnimeCell: UICollectionViewCell?
    var lastFetchDateTime: Date?
    var currentLongPressCellStatus: (isFavorite: Bool?, isNotify: Bool?, status: String?, animeID: Int?)
    private var cancellables: Set<AnyCancellable> = []
    
    let fetchMoreDataTrigger = PassthroughSubject<Void, Never>()
    
    init() {
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
        
        fetchMoreDataTrigger
            .throttle(for: 2, scheduler: RunLoop.main, latest: false)
            .sink { _ in
                guard let currentPage = self.animeTrendingData?.data.page.pageInfo.currentPage else {
                    return
                }
                
                self.fetchMoreTrendingAnimeData(currentPage: currentPage + 1)
            }
            .store(in: &self.cancellables)
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
    
    func fetchMoreTrendingAnimeDataTrigger() {
        fetchMoreDataTrigger.send(())
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

struct AnimeTrending: Codable {
    var data: Page
    
    struct Page: Codable {
        var page: PageInfoAndMedia
        
        enum CodingKeys: String, CodingKey {
            case page = "Page"
        }
        
        struct PageInfoAndMedia: Codable {
            var media: [Anime]
            var pageInfo: PageInfo
            
            struct Anime: Codable {
                let id: Int
                let title: Title
                let coverImage: CoverImage
                
                struct Title: Codable {
                    let native: String?
                    let english: String?
                    let romaji: String?
                }
                
                struct CoverImage: Codable {
                    let extraLarge: String
                }
            }
            
            struct PageInfo: Codable {
                var currentPage: Int
                var hasNextPage: Bool
            }
        }
    }
    
    
    
}
