//
//  LoginMockData.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/4.
//

import Foundation
import Combine
import FirebaseFirestore

final class LoginMockData: FirebaseDataProvider {
    
    func resetFavoritePagination() {
        // Do nothing
    }
    
    func updateAnimeRecord(userUID: String, animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.FirebaseAnimeRecord, any Error> {
        return Just(Response.FirebaseAnimeRecord(id: 0, isFavorite: false, isNotify: false))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getCurrentUserUID() -> String? {
        return nil
    }
    
    func loadUserFavorite(perFetch: Int) -> AnyPublisher<[Response.FirebaseAnimeRecord], any Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func signIn(withEmail: String, password: String) -> AnyPublisher<Void, any Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
