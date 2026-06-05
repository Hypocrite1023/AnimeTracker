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
    
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.LocalAnimeRecord, any Error> {
        return Just(Response.LocalAnimeRecord(id: 0, isFavorite: false, isNotify: false))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadUserFavorite(perFetch: Int) -> AnyPublisher<[Response.LocalAnimeRecord], any Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
