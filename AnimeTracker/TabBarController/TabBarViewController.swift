//
//  TabBarViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import UIKit
import UserNotifications
import Combine

class TabBarViewController: UITabBarController {
    
    private let vm = TabBarViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        
        requestNotificationPermission()
            .sink { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    AnimeNotification.shared.notificationEnable = true
                    
                    // 執行本地通知檢查與狀態更新（原本由 UserCache 執行）
                    AnimeNotification.shared.checkNotification()
                        .flatMap { animeIDs in
                            animeIDs.map { ($0.key, AnimeInfo.AnimeStatus(rawValue: $0.value) ?? AnimeInfo.AnimeStatus.finished) }.publisher
                                .flatMap(maxPublishers: .max(5)) { (animeID, status) -> AnyPublisher<Void, Never> in
                                    LocalRecordManager.shared.updateAnimeStatus(animeID: animeID, status: status)
                                }
                                .collect()
                                .eraseToAnyPublisher()
                        }
                        .sink { _ in
                            print("Notification check finished...")
                        }
                        .store(in: &self.cancellables)
                }
            }
            .store(in: &cancellables)
    }
    
    func requestNotificationPermission() -> AnyPublisher<Bool, Never> {
        let center = UNUserNotificationCenter.current()
        
        return Future<Bool, Never> { promise in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension TabBarViewController: NavigateDelegate {
    func navigateTo(page: Int) {
        print(page)
        self.selectedIndex = page
    }
}
