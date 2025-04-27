//
//  NavigationViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import UIKit
import Combine

class NavigationViewController: UINavigationController {

    private var cancellables = Set<AnyCancellable>()
    
    // when fetching data it will show
    let fetchingDataIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnimeDataFetcher.shared.$isFetchingData
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] isFetching in
                self?.fetchingDataIndicator.isHidden = isFetching
                if isFetching {
                    print(";;;; is fetching data ;;;;;")
                    self?.fetchingDataIndicator.startAnimating()
                } else {
                    print(";;;; end fetching data ;;;;;")
                    self?.fetchingDataIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        fetchingDataIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(fetchingDataIndicator)
        fetchingDataIndicator.isHidden = true
        fetchingDataIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        fetchingDataIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        
//        clearAllUserDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // check the user is email verify
        guard FirebaseManager.shared.isAuthenticatedAndEmailVerified() else {
            print("need login")
            let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
            self.viewControllers = [loginPage]
            return
        }
        print("login success")
        let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        self.viewControllers = [mainPage]
    }
    
    func clearAllUserDefaults() {
        let defaults = UserDefaults.standard
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }
}


