//
//  FavoritePageViewModel.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2025/7/8.
//

import Foundation
import Combine

class FavoritePageViewModel {
    let input: Input!
    var output: Output!
    
    struct Input {
        let shouldShowFavorite: PassthroughSubject<Void, Never> = .init()
        let shouldShowTimeline: PassthroughSubject<Void, Never> = .init()
        let onTapAnime: PassthroughSubject<Int, Never> = .init()
    }
    
    struct Output {
        var showFavorite: AnyPublisher<Void, Never> = .empty
        var showTimeline: AnyPublisher<Void, Never> = .empty
        var shouldNavigateToAnimeDetail: AnyPublisher<Int, Never> = .empty
    }
    
    init() {
        input = Input()
        output = Output()
        setupPublishers()
    }
    
    private func setupPublishers() {
        output.showFavorite = input.shouldShowFavorite
            .eraseToAnyPublisher()
        output.showTimeline = input.shouldShowTimeline
            .eraseToAnyPublisher()
        output.shouldNavigateToAnimeDetail = input.onTapAnime
            .eraseToAnyPublisher()
    }
}
