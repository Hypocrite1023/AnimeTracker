//
//  LoginMockData.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/4.
//

import Foundation
import Combine

final class LoginMockData: FirebaseDataProvider {
    func signIn(withEmail: String, password: String) -> AnyPublisher<Void, any Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
