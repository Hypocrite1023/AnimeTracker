//
//  ResetPasswordViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/27.
//

import Foundation
import Combine

class ResetPasswordViewModel {
    var emailAddress: String?
    
    func resetPassword() -> AnyPublisher<Void, Error> {
        guard let emailAddress = emailAddress, !emailAddress.isEmpty else {
            return Fail(error: ResetPasswordError.emailAddressEmpty)
                .eraseToAnyPublisher()
        }
        
        return FirebaseManager.shared.resetPassword(withEmail: emailAddress)
    }
}

enum ResetPasswordError: Error {
    case emailAddressEmpty
    
    var description: String {
        switch self {
        case .emailAddressEmpty:
            return "Email address field cannot be empty."
        }
    }
}
