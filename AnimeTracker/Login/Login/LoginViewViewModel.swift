//
//  LoginViewViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/25.
//

import Foundation
import Combine

class LoginViewViewModel {
    // MARK: - input
    let didPressLogin: PassthroughSubject<Void, Never> = .init()
    let didPressRegister: PassthroughSubject<Void, Never> = .init()
    let didPressForgotPassword: PassthroughSubject<Void, Never> = .init()
    
    // MARK: - output
    var shouldNavigateToHomePage: AnyPublisher<Bool, Never> = .empty
    var shouldNavigateToRegister: AnyPublisher<Void, Never> = .empty
    var shouldNavigateToForgotPassword: AnyPublisher<Void, Never> = .empty
    var shouldShowError: AnyPublisher<Error, Never> = .empty
    
    // MARK: - data property
    @Published var userEmail: String?
    @Published var userPassword: String?
    @Published var errorMessage: Error?
    private let loginDataProvider: FirebaseDataProvider
    private var cancellables: Set<AnyCancellable> = []
    
    init(loginDataProvider: FirebaseDataProvider = FirebaseManager.shared) {
        self.loginDataProvider = loginDataProvider
        setupPublisher()
    }
    
    func login() -> AnyPublisher<Void, Error> {
        guard let userEmail, userEmail != "" else {
            return Fail(error: LoginError.emailFieldEmpty).eraseToAnyPublisher()
        }
        
        guard let userPassword, userPassword != "" else {
            return Fail(error: LoginError.passwordFieldEmpty).eraseToAnyPublisher()
        }
        
        return loginDataProvider.signIn(withEmail: userEmail, password: userPassword)
    }
    
    private func setupPublisher() {
        shouldNavigateToHomePage = didPressLogin
            .flatMap { [weak self] _ -> AnyPublisher<Bool, Never> in
                guard let self else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                return self.login()
                    .map { _ in true }
                    .catch { error in
                        self.errorMessage = error
                        return Just(false).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        shouldNavigateToRegister = didPressRegister
            .eraseToAnyPublisher()
        
        shouldNavigateToForgotPassword = didPressForgotPassword
            .eraseToAnyPublisher()
        
        shouldShowError = $errorMessage
            .compactMap{ $0 }
            .eraseToAnyPublisher()
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
