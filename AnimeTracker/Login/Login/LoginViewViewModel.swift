//
//  LoginViewViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/25.
//

import Foundation
import Combine

class LoginViewViewModel {
    @Published var userEmail: String?
    @Published var userPassword: String?
    private var cancellables: Set<AnyCancellable> = []
    
    func login() -> AnyPublisher<Void, Error> {
        guard let userEmail, userEmail != "" else {
            return Fail(error: LoginError.emailFieldEmpty).eraseToAnyPublisher()
        }
        
        guard let userPassword, userPassword != "" else {
            return Fail(error: LoginError.passwordFieldEmpty).eraseToAnyPublisher()
        }
        
        return FirebaseManager.shared.signIn(withEmail: userEmail, password: userPassword)
    }
}

enum LoginError: Error {
    case emailFieldEmpty
    case passwordFieldEmpty
    case networkError
    
    var description: String {
        switch self {
        case .emailFieldEmpty:
            return "User email field should not empty."
        case .passwordFieldEmpty:
            return "User password field should not empty."
        case .networkError:
            return "Network error."
        }
    }
}
