//
//  RegisterViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/27.
//

import Foundation
import Combine

class RegisterViewModel {
    var username: String?
    var userEmail: String?
    var userPassword: String?
    var confirmPassword: String?
    
    func register() -> AnyPublisher<Void, Error> {
        guard let username = username, !username.isEmpty else {
            return Fail(error: RegisterError.usernameEmpty)
                .eraseToAnyPublisher()
        }
        guard let userEmail = userEmail, !userEmail.isEmpty else {
            return Fail(error: RegisterError.emailEmpty)
                .eraseToAnyPublisher()
        }
        guard let userPassword = userPassword, !userPassword.isEmpty else {
            return Fail(error: RegisterError.passwordEmpty)
                .eraseToAnyPublisher()
        }
        guard let confirmPassword = confirmPassword, !confirmPassword.isEmpty else {
            return Fail(error: RegisterError.confirmPasswordEmpty)
                .eraseToAnyPublisher()
        }
        guard userPassword == confirmPassword else {
            return Fail(error: RegisterError.passwordNotMatch)
                .eraseToAnyPublisher()
        }
        
        return FirebaseManager.shared.register(withEmail: userEmail, password: userPassword, username: username)
    }
}

enum RegisterError: Error {
    case usernameEmpty, emailEmpty, passwordEmpty, confirmPasswordEmpty, passwordNotMatch, createUsernameFail, sendVerifyEmailFail
    
    var description: String {
        switch self {
            
        case .usernameEmpty:
            return "Username shouldn't be empty."
        case .emailEmpty:
            return "Email shouldn't be empty."
        case .passwordEmpty:
            return "Password shouldn't be empty."
        case .confirmPasswordEmpty:
            return "Confirm password field shouldn't be empty."
        case .passwordNotMatch:
            return "Password doesn't match."
        case .createUsernameFail:
            return "Fail to create username."
        case .sendVerifyEmailFail:
            return "Fail to send verify email."
        }
    }
}
