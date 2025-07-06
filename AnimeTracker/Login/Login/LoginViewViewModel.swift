//
//  LoginViewViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/25.
//

import Foundation
import Combine
import CombineExt

class LoginViewViewModel {
    // MARK: - input
    struct Input {
        let didPressLogin: PassthroughSubject<Void, Never> = .init()
        let didPressRegister: PassthroughSubject<Void, Never> = .init()
        let didPressForgotPassword: PassthroughSubject<Void, Never> = .init()
    }
    
    // MARK: - output
    struct Output {
        var shouldNavigateToHomePage: AnyPublisher<Bool, Never> = .empty
        var shouldNavigateToRegister: AnyPublisher<Void, Never> = .empty
        var shouldNavigateToForgotPassword: AnyPublisher<Void, Never> = .empty
        var shouldShowError: AnyPublisher<Error, Never> = .empty
        var isLoggingProcessing: CurrentValueSubject<Bool, Never> = .init(false)
    }
    
    // MARK: - data property
    let input = Input()
    private(set) var output = Output()
    var userEmail = CurrentValueSubject<String, Never>("")
    var userPassword = CurrentValueSubject<String, Never>("")
    @Published var errorMessage: Error?
    private let loginDataProvider: FirebaseDataProvider
    private var cancellables: Set<AnyCancellable> = []
    
    init(loginDataProvider: FirebaseDataProvider = FirebaseManager.shared) {
        self.loginDataProvider = loginDataProvider
        setupPublisher()
    }
    
    func login() -> AnyPublisher<Void, Error> {
        switch validateCredentials() {
        case .success(let (email, password)):
            return loginDataProvider.signIn(withEmail: email, password: password)
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    private func setupPublisher() {
        output.shouldNavigateToHomePage = input.didPressLogin
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.output.isLoggingProcessing.value = true
            })
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
                    .handleEvents(receiveOutput: { _ in
                        self.output.isLoggingProcessing.value = false
                    })
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        output.shouldNavigateToRegister = input.didPressRegister
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
            .eraseToAnyPublisher()
        
        output.shouldNavigateToForgotPassword = input.didPressForgotPassword
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
            .eraseToAnyPublisher()
        
        output.shouldShowError = $errorMessage
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }
    
    private func validateCredentials() -> Result<(String, String), LoginError> {
        guard !userEmail.value.isEmpty else {
            return .failure(.emailFieldEmpty)
        }
        
        guard !userPassword.value.isEmpty else {
            return .failure(.passwordFieldEmpty)
        }
        
        return .success((userEmail.value, userPassword.value))
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
