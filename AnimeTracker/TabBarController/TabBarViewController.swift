//
//  TabBarViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import UIKit
import FirebaseAuth
import UserNotifications
import Combine

class TabBarViewController: UITabBarController {
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // logout
        let logoutAction = UIAction(title: "Logout", image: UIImage(systemName: "figure.walk")) { action in
            do {
                AnimeNotification.shared.removeAllNotification() // remove all notification that record in user default
                print("remove all notification.")
                try Auth.auth().signOut()
                let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
                self.navigationController?.setViewControllers([loginPage], animated: true) // navigate to login page
            } catch {
                print(error)
            }
        }
        
        let menu = UIMenu(title: "Options", children: [logoutAction])
        if let userName = Auth.auth().currentUser?.displayName {
            navigationItem.title = "Hello, \(userName)"
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), menu: menu)
        }
        requestNotificationPermission() // request notification permission
            .sink { granted in
                if granted {
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
                } else {
                    print("Notification permission denied.")
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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


