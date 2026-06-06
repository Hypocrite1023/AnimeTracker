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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupUI() {
        navigationItem.title = nil
        navigationItem.rightBarButtonItem = nil
        
        requestNotificationPermission()
            .flatMap { granted -> AnyPublisher<[Int: String], Never> in
                if granted {
                    AnimeNotification.shared.notificationEnable = true
                    return AnimeNotification.shared.checkNotification()
                } else {
                    return Empty().eraseToAnyPublisher()
                }
            }
            .flatMap { animeIDs -> AnyPublisher<[Void], Never> in
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
