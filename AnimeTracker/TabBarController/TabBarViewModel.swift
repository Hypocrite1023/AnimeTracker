//
//  TabBarViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/5.
//

import Foundation
import Combine

class TabBarViewModel {
    // MARK: - Data property
    var isLogin: Bool {
        return FirebaseManager.shared.isAuthenticatedAndEmailVerified()
    }
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - input
    let shouldShowLoginPage: PassthroughSubject<Void, Never> = .init()
    // MARK: - output
    private(set) var showLoginPage: AnyPublisher<Void, Never> = .empty
    
    init() {
        showLoginPage = shouldShowLoginPage
            .map {
                return $0
            }
            .filter { !self.isLogin }
            .eraseToAnyPublisher()
    }
    
    func signOut() {
        FirebaseManager.shared.signOut()
    }
    
    
}
