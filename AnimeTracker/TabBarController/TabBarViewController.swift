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
    
    private let vm = TabBarViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        subscribeVM()
    }
    
    func setupUI() {
        
        UserCache.shared.$userUID
            .removeDuplicates()
            .sink { [weak self] userUID in
                guard let self = self else { return }
                if let userUID = userUID {
                    let logoutAction = UIAction(title: "Logout", image: UIImage(systemName: "figure.walk.departure")) { action in
                        self.vm.signOut()
                    }
                    let menu = UIMenu(title: "Options", children: [logoutAction])
                    
                    if let userName = Auth.auth().currentUser?.displayName { // 已登入
                        self.navigationItem.title = "Hello, \(userName)"
                        
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), menu: menu)
                    } else { // 已登入 未有 username
                        navigationItem.title = "Hello!"
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), menu: menu)
                    }
                    requestNotificationPermission() // request notification permission
                        .sink { granted in
                            if granted {
                                AnimeNotification.shared.notificationEnable = true
                            }
                        }
                        .store(in: &self.cancellables)
                } else {
                    navigationItem.title = "Hello!"
                    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "figure.walk.arrival"), style: .plain, target: self, action: #selector(sendLoginSignal))
                }
            }
            .store(in: &cancellables)
        
    }
    
    func subscribeVM() {
        vm.showLoginPage
            .sink { [weak self] _ in
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginPage")
                self?.navigationItem.backButtonTitle = "Trending"
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &self.cancellables)
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
    
    @objc func sendLoginSignal() {
        self.vm.shouldShowLoginPage.send(())
    }
}

extension TabBarViewController: NavigateDelegate {
    func navigateTo(page: Int) {
        print(page)
        self.selectedIndex = page
    }
}


