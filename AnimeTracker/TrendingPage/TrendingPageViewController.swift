//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/18.
//

import UIKit
import Combine
import SwiftUI

class TrendingPageViewController: UIViewController {
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    
    private let viewModel: TrendingPageViewModel = TrendingPageViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    private var lastContentOffsetY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if lastContentOffsetY == nil {
            lastContentOffsetY = 0
        }
    }
    
    private func setupUI() {
        trendingCollectionView?.isHidden = true // Hide the collection view storyboard element
        
        let swiftUIView = TrendingView(
            viewModel: viewModel,
            onAnimeTap: { [weak self] animeID in
                let vc = AnimeDetailsViewController(animeID: animeID)
                self?.navigationController?.pushViewController(vc, animated: true)
            },
            onScroll: { [weak self] minY in
                guard let self = self else { return }
                let contentOffsetY = -minY
                if let lastContentOffsetY = self.lastContentOffsetY, contentOffsetY > 0 {
                    if contentOffsetY > lastContentOffsetY + 30 {
                        self.lastContentOffsetY = contentOffsetY
                        self.setTabBar(hidden: true, animated: true)
                    } else if contentOffsetY < lastContentOffsetY - 30 {
                        self.lastContentOffsetY = contentOffsetY
                        self.setTabBar(hidden: false, animated: true)
                    }
                }
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}

// MARK: - Tab Bar Auto Hiding (UIKit support)
extension TrendingPageViewController {
    func setTabBar(hidden: Bool, animated: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else { return }
        let isHidden = tabBar.frame.origin.y >= UIScreen.main.bounds.height
        if hidden == isHidden { return }

        let height = tabBar.frame.size.height
        let offsetY = hidden ? height : -height

        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            tabBar.frame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        }
    }
}
