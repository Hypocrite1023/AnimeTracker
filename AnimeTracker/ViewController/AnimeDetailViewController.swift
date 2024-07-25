//
//  AnimeDetailViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/19.
//

import UIKit

class AnimeDetailViewController: UIViewController {
    
    var animeFetchingDataManager: AnimeFetchData
    var animeMediaID: Int
    var animeDetailData: MediaResponse.MediaData.Media?
    var animeDetailView: AnimeDetailView!
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private lazy var overviewView: OverviewView = {
        let view = OverviewView(frame: .zero)
        view.animeDescriptionDelegate = self
        return view
    }()
    
    private lazy var watchView: WatchView = {
        let view = WatchView(frame: .zero)
        view.streamingDetailDelegate = self
        return view
    }()
    
    init(animeFetchingDataManager: AnimeFetchData, mediaID: Int) {
        self.animeFetchingDataManager = animeFetchingDataManager
        self.animeMediaID = mediaID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.animeFetchingDataManager.animeDetailDataDelegate = self
        animeFetchingDataManager.fetchAnimeByID(id: animeMediaID)
        animeDetailView = AnimeDetailView(frame: self.view.frame)
//        animeDetailView.frame = self.view.frame
        self.view.addSubview(animeDetailView)
        self.view.backgroundColor = .white
//        self.setupConstraints()
        setupPortraitConstraint()
        setupLandscapeConstraint()
        setupInitialConstraint()
//        self.setupButtonFunctions()
        print("view did load")
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("transition")
        watchView.streamingEpisodeCollectionView.collectionViewLayout.invalidateLayout()
        coordinator.animate(alongsideTransition: { _ in
            if let windowScene = self.view.window?.windowScene {
                let orientation = windowScene.interfaceOrientation
                if orientation.isLandscape {
                    self.view.frame = self.view.bounds
                    self.animeDetailView.frame = self.view.bounds
                    NSLayoutConstraint.deactivate(self.portraitConstraints)
                    NSLayoutConstraint.activate(self.portraitConstraints)
                    print("橫向")
                } else if orientation.isPortrait {
                    self.view.frame = self.view.bounds
                    self.animeDetailView.frame = self.view.bounds
                    NSLayoutConstraint.activate(self.portraitConstraints)
                    NSLayoutConstraint.deactivate(self.landscapeConstraints)
                    print("縱向")
                }
            }
        }, completion: nil)
    }
    
    private func setupInitialConstraint() {
        if self.view.bounds.width > self.view.bounds.height {
            // landscape
            NSLayoutConstraint.deactivate(self.portraitConstraints)
            NSLayoutConstraint.activate(self.landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(self.landscapeConstraints)
            NSLayoutConstraint.activate(self.portraitConstraints)
        }
    }
    
    private func setupPortraitConstraint() {
        portraitConstraints = [
            animeDetailView.tmpScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            animeDetailView.tmpScrollView.leadingAnchor.constraint(equalTo: animeDetailView.safeAreaLayoutGuide.leadingAnchor),
            animeDetailView.tmpScrollView.trailingAnchor.constraint(equalTo: animeDetailView.safeAreaLayoutGuide.trailingAnchor),
            animeDetailView.tmpScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
//            animeDetailView.tmpScrollView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            
            animeDetailView.animeBannerView.topAnchor.constraint(equalTo: animeDetailView.tmpScrollView.topAnchor),
            animeDetailView.animeBannerView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.safeAreaLayoutGuide.leadingAnchor),
            animeDetailView.animeBannerView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor),
            animeDetailView.animeBannerView.heightAnchor.constraint(equalToConstant: 370),
            
            animeDetailView.animeInformationScrollView.topAnchor.constraint(equalTo: animeDetailView.animeBannerView.bottomAnchor, constant: 20),
            animeDetailView.animeInformationScrollView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 10),
            
            animeDetailView.animeInformationScrollView.heightAnchor.constraint(equalToConstant: 70),
            animeDetailView.animeInformationScrollView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor, constant: -20),

            animeDetailView.animeDescriptionView.topAnchor.constraint(equalTo: animeDetailView.animeInformationScrollView.bottomAnchor, constant: 20),
            animeDetailView.animeDescriptionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.animeDescriptionView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor),
            
            animeDetailView.relationView.topAnchor.constraint(equalTo: animeDetailView.animeDescriptionView.bottomAnchor),
            animeDetailView.relationView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.relationView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
            animeDetailView.relationView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor),
            animeDetailView.relationView.heightAnchor.constraint(equalToConstant: 200),
            animeDetailView.relationView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor),
            
        ]
    }
    
    private func setupLandscapeConstraint() {
        landscapeConstraints = [
            animeDetailView.tmpScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            animeDetailView.tmpScrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            animeDetailView.tmpScrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            animeDetailView.tmpScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            animeDetailView.tmpScrollView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            
            animeDetailView.animeBannerView.topAnchor.constraint(equalTo: animeDetailView.tmpScrollView.topAnchor),
            animeDetailView.animeBannerView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.animeBannerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            animeDetailView.animeBannerView.heightAnchor.constraint(equalToConstant: 370),
            
            animeDetailView.animeInformationScrollView.topAnchor.constraint(equalTo: animeDetailView.animeBannerView.bottomAnchor, constant: 20),
            animeDetailView.animeInformationScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            animeDetailView.animeInformationScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),

            animeDetailView.animeDescriptionView.topAnchor.constraint(equalTo: animeDetailView.animeInformationScrollView.bottomAnchor, constant: 20),
            animeDetailView.animeDescriptionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.animeDescriptionView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
//            animeDetailView.animeDescriptionView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor),
            
            animeDetailView.relationView.topAnchor.constraint(equalTo: animeDetailView.animeDescriptionView.bottomAnchor),
            animeDetailView.relationView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.safeAreaLayoutGuide.leadingAnchor),
            animeDetailView.relationView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            animeDetailView.relationView.heightAnchor.constraint(equalToConstant: 200),
            animeDetailView.relationView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor),
            
        ]
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

extension AnimeDetailViewController: AnimeDetailDataDelegate {
    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media) {
        self.animeDetailData = media
//        print(media.streamingEpisodes)
        DispatchQueue.main.async {
            self.animeDetailView?.setupAnimeInfoPage(animeDetailData: self.animeDetailData!)
//            self.switchToOverviewPage(sender: self.animeDetailView.overviewButton)
        }
        print("load view")
    }
    
}

extension AnimeDetailViewController: AnimeDescriptionDelegate {
    func passDescriptionAndUpdate() -> String {
        return animeDetailData?.description ?? ""
    }
}

extension AnimeDetailViewController: AnimeStreamingDetailDelegate {
    func passStreamingDetail() -> [MediaResponse.MediaData.Media.StreamingEpisodes] {
        return animeDetailData?.streamingEpisodes ?? []
    }
    
    func passStreamingDetailCount() -> Int {
        return animeDetailData?.streamingEpisodes.count ?? 0
    }
    
    
}
