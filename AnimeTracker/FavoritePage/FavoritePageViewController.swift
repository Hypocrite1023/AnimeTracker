//
//  FavouritePageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import SwiftUI
import Combine

/*
 favorite
 My favorite
 releasing, finished, Not yet airing 分這三個 section, section 可以摺疊展開，預設 releasing 為展開 其他折疊
 
 Timeline
 將 user favorite 的 anime 依照動畫播放的日期排列
 */

class FavoritePageViewController: UIViewController {
    // MARK: - UI Property
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    private var favoriteView: UIView?
    
    // MARK: - Data Property
    private let viewModel: FavoritePageViewModel = FavoritePageViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    func setupUI() {
        let favoriteUIHostingController = UIHostingController(rootView: FavoriteView(animeTapCallBackSubject: viewModel.input.onTapAnime))
        favoriteView = favoriteUIHostingController.view
        self.addChild(favoriteUIHostingController)
        
        guard let favoriteView else {
            return
        }
        
        containerView.addSubview(favoriteView)
        
        favoriteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        segmentControl.isHidden = true
        containerView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
        
        favoriteView.isHidden = false
    }
    
    func setupBinding() {
        // MARK: - Subscribe
        viewModel.output.shouldNavigateToAnimeDetail
            .sink { animeID in
                let vc = AnimeDetailsViewController(animeID: animeID)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
    }
}
