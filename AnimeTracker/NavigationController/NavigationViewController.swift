//
//  NavigationViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import UIKit
import Combine
import Kingfisher
import SnapKit

class NavigationViewController: UINavigationController {
    private var cancellables = Set<AnyCancellable>()
    
    // when fetching data it will show
    let fetchingDataIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024 // 100MB
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
        
        self.view.addSubview(fetchingDataIndicator)
        fetchingDataIndicator.isHidden = true
        fetchingDataIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
//        clearAllUserDefaults()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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


