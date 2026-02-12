//
//  TimelineViewViewModel.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation
import Combine

class TimelineViewViewModel: ObservableObject {
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var currentPagePublisher = 1
    @Published var animeLists: [Response.AnimeTimelineData] = []
    @Published var passedSeconds: Int = 0
    
    init() {
        Just(())
            .combineLatest($currentPagePublisher)
            .flatMap { _, page in
                AnimeDataFetcher.shared.fetchAnimeListBySeason(year: 2026, season: "WINTER", page: page)
            }
            .sink { _ in
                
            } receiveValue: { [weak self] result in
                self?.animeLists.append(contentsOf: result.data.Page.media)
                self?.animeLists.sort {
                    $0.nextAiringEpisode?.timeUntilAiring ?? Int.max < $1.nextAiringEpisode?.timeUntilAiring ?? Int.max
                }
                if result.data.Page.pageInfo.hasNextPage {
                    self?.currentPagePublisher += 1
                }
            }
            .store(in: &cancellables)
        
        $animeLists
            .sink {
                print($0.count)
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 1, on: RunLoop.main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.passedSeconds += 1
            }
            .store(in: &cancellables)
    }
}
