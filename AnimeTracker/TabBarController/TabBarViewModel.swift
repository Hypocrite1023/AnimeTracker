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
    let shouldCheckNotification: PassthroughSubject<Void, Never> = .init()
    let shouldShowLoginPage: PassthroughSubject<Void, Never> = .init()
    // MARK: - output
    private(set) var showLoginPage: AnyPublisher<Void, Never> = .empty
    
    init() {
        shouldCheckNotification
            .sink { [weak self] _ in
                guard let self = self else { return }
                AnimeNotification.shared.checkNotification()
                    .flatMap { (userUID, animeIDs) in
                        animeIDs.map { ($0.key, AnimeInfo.AnimeStatus(rawValue: $0.value) ?? AnimeInfo.AnimeStatus.finished) }.publisher
                            .flatMap(maxPublishers: .max(5)) { (animeID, status) -> AnyPublisher<Void, Never> in
                                FirebaseManager.shared.updateAnimeStatus(userUID: userUID, animeID: animeID, status: status)
                            }
                            .collect()
                            .eraseToAnyPublisher()
                    }
                    .sink { _ in
                        print("Notification check finished...")
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
        
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
