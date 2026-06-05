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
        navigationItem.title = "AnimeTracker"
        navigationItem.rightBarButtonItem = nil
        
        requestNotificationPermission()
            .sink { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    AnimeNotification.shared.notificationEnable = true
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
