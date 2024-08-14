//
//  NavigationViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import UIKit
import Combine
import FirebaseAuth

class NavigationViewController: UINavigationController {

    private var cancellables = Set<AnyCancellable>()
    var fetchingDataIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        print("view did appear")
        if let verified = Auth.auth().currentUser?.isEmailVerified {
            if verified {
                print("login success")
                let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                self.viewControllers = [mainPage]
            } else {
                print("need login")
                let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
                self.viewControllers = [loginPage]
            }
        } else {
            print("need login")
            let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
            self.viewControllers = [loginPage]
        }
    }
    
    func clearAllUserDefaults() {
        let defaults = UserDefaults.standard
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


