//
//  LoginMockData.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/4.
//

import Foundation
import Combine

final class LoginMockData: UserDataProvider {
    
    func resetFavoritePagination() {
        // Do nothing
    }
    
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String, userStatus: UserAnimeStatus?) -> AnyPublisher<Response.LocalAnimeRecord, any Error> {
        return Just(Response.LocalAnimeRecord(id: 0, isFavorite: false, isNotify: false, userStatus: .planToWatch, addedAt: Date(), updatedAt: Date()))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadUserFavorite(perFetch: Int, userStatus: UserAnimeStatus?, sortBy: FavoriteSortOption) -> AnyPublisher<[Response.LocalAnimeRecord], any Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
