//
//  UserCache.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/6.
//

import Foundation
import Combine

class UserCache {
    static let shared = UserCache()
    @Published var userUID: String? = FirebaseManager.shared.getCurrentUserUID()
    
    private init() {
        $userUID
            .removeDuplicates()
            .sink { userUID in
                if let userUID = userUID {
                    AnimeNotification.shared.checkNotification(userUID: userUID)
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
                } else {
                    AnimeNotification.shared.removeAllNotification()
                }
                
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    
}
