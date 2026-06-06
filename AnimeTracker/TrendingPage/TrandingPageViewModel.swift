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
    
    // MARK: - Core Data & Notification Helper APIs (SwiftUI Refactored - Async/Await)
    
    func getLocalRecord(for animeID: Int) -> AnyPublisher<Response.LocalAnimeRecord?, Error> {
        return LocalRecordManager.shared.getAnimeRecord(animeID: animeID)
    }
    
    @MainActor
    func refreshData() async {
        do {
            for try await trendingData in AnimeDataFetcher.shared.fetchAnimeByTrending(page: 1).values {
                self.animeTrendingData = trendingData
                break
            }
        } catch {
            print("Error refreshing data: \(error)")
        }
    }
    
    @MainActor
    func toggleFavorite(animeID: Int, isNotify: Bool, status: String, currentFavorite: Bool) async throws -> Bool {
        let newFavorite = !currentFavorite
        for try await _ in LocalRecordManager.shared.addAnimeRecord(animeID: animeID, isFavorite: newFavorite, isNotify: isNotify, status: status).values {
            break
        }
        return newFavorite
    }
    
    @MainActor
    func toggleNotification(animeID: Int, isFavorite: Bool, status: String, currentNotify: Bool) async throws -> Bool {
        let newNotify = !currentNotify
        
        if newNotify {
            try await createLocalNotification(for: animeID)
        } else {
            removeLocalNotification(for: animeID)
        }
        
        for try await _ in LocalRecordManager.shared.addAnimeRecord(animeID: animeID, isFavorite: isFavorite, isNotify: newNotify, status: status).values {
            break
        }
        
        return newNotify
    }
    
    private func createLocalNotification(for animeID: Int) async throws {
        for try await episodesData in AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: animeID).values {
            if let nextAiringEpisode = episodesData.data.Media.nextAiringEpisode,
               let episodes = episodesData.data.Media.episodes {
                AnimeNotification.shared.setupAllEpisodeNotification(
                    animeID: animeID,
                    animeTitle: episodesData.data.Media.title.native,
                    nextAiringEpsode: nextAiringEpisode.episode,
                    nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring),
                    totalEpisode: episodes
                )
            }
            break
        }
    }
    
    private func removeLocalNotification(for animeID: Int) {
        AnimeNotification.shared.removeAllEpisodeNotification(for: animeID)
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
