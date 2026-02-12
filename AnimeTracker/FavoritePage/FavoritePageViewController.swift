//
//  FavouritePageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
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
    private var timelineView: UIView?
    
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
        
        let timelineUIHostingController = UIHostingController(rootView: TimelineView())
        timelineView = timelineUIHostingController.view
        self.addChild(timelineUIHostingController)
        
        guard let favoriteView, let timelineView else {
            return
        }
        
        containerView.addSubview(favoriteView)
        containerView.addSubview(timelineView)
        
        favoriteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        timelineView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        segmentControl.selectedSegmentIndex = 0
        favoriteView.isHidden = false
        timelineView.isHidden = true
    }
    
    func setupBinding() {
        // MARK: - Publish
        segmentControl.publisher(for: \.selectedSegmentIndex)
            .sink { [weak self] index in
                switch index {
                case 0:
                    self?.viewModel.input.shouldShowFavorite.send(())
                case 1:
                    self?.viewModel.input.shouldShowTimeline.send(())
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // MARK: - Subscribe
        viewModel.output.showFavorite
            .sink { [weak self] in
                self?.favoriteView?.isHidden = false
                self?.timelineView?.isHidden = true
            }
            .store(in: &cancellables)
        
        viewModel.output.showTimeline
            .sink { [weak self] in
                self?.favoriteView?.isHidden = true
                self?.timelineView?.isHidden = false
            }
            .store(in: &cancellables)
        
        viewModel.output.shouldNavigateToAnimeDetail
            .sink { animeID in
                let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(identifier: "AnimeDetailView") as! AnimeDetailPageViewController
                vc.viewModel = AnimeDetailPageViewModel(animeID: animeID)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
    }
}
