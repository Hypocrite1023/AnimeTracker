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
    private var bindings: Set<AnyCancellable> = []
    var currentPage: Int = 1
    
    init() {
        AnimeDataFetcher.shared.fetchAnimeByTrending(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        self.currentPage += 1
                    case .failure(let error):
                        print(error)
                        break
                }
            } receiveValue: { trendingData in
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeTrendingData = trendingData
            }
            .store(in: &bindings)

    }
    
    func fetchMoreTrendingAnimeData() {
        AnimeDataFetcher.shared.fetchAnimeByTrending(page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .finished:
                        self.currentPage += 1
                    case .failure(_):
                        break
                }
            } receiveValue: { trendingData in
                self.animeTrendingData?.data.page.media.append(contentsOf: trendingData.data.page.media)
                self.animeTrendingData?.data.page.pageInfo = trendingData.data.page.pageInfo
                self.currentPage = trendingData.data.page.pageInfo.currentPage + 1
            }
            .store(in: &bindings)
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
