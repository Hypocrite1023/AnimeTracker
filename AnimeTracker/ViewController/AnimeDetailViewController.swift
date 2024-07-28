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
        animeDetailView.tmpScrollView.delegate = self
        self.view.backgroundColor = .white
//        self.setupConstraints()
//        setupPortraitConstraint()
//        setupLandscapeConstraint()
//        setupInitialConstraint()
//        self.setupButtonFunctions()
        print("view did load")
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("transition")
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
            
            animeDetailView.characterView.topAnchor.constraint(equalTo: animeDetailView.relationView.bottomAnchor, constant: 10),
            animeDetailView.characterView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.characterView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
            
            animeDetailView.staffView.topAnchor.constraint(equalTo: animeDetailView.characterView.bottomAnchor, constant: 10),
            animeDetailView.staffView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.staffView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
            
            animeDetailView.statusDistributionView.topAnchor.constraint(equalTo: animeDetailView.staffView.bottomAnchor, constant: 20),
            animeDetailView.statusDistributionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 5),
            animeDetailView.statusDistributionView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor, constant: -5),
//            animeDetailView.statusDistributionView.heightAnchor.constraint(equalToConstant: 300),
            
            animeDetailView.scoreDistributionView.topAnchor.constraint(equalTo: animeDetailView.statusDistributionView.bottomAnchor, constant: 15),
            animeDetailView.scoreDistributionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.scoreDistributionView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
            animeDetailView.scoreDistributionView.heightAnchor.constraint(equalToConstant: 175),
            
            animeDetailView.watchView.topAnchor.constraint(equalTo: animeDetailView.scoreDistributionView.bottomAnchor, constant: 15),
            animeDetailView.watchView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.watchView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
//            animeDetailView.watchView.heightAnchor.constraint(equalToConstant: 300),
            
            animeDetailView.recommendationsView.topAnchor.constraint(equalTo: animeDetailView.watchView.bottomAnchor, constant: 15),
            animeDetailView.recommendationsView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 5),
            animeDetailView.recommendationsView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor, constant: -5),
            animeDetailView.recommendationsView.heightAnchor.constraint(equalToConstant: 250),
            
            animeDetailView.reviewView.topAnchor.constraint(equalTo: animeDetailView.recommendationsView.bottomAnchor, constant: 15),
            animeDetailView.reviewView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 5),
            animeDetailView.reviewView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor, constant: -5),
//            animeDetailView.reviewView.heightAnchor.constraint(equalToConstant: 250),

            animeDetailView.externalLinkView.topAnchor.constraint(equalTo: animeDetailView.reviewView.bottomAnchor, constant: 15),
            animeDetailView.externalLinkView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.externalLinkView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
            
            animeDetailView.tagView.topAnchor.constraint(equalTo: animeDetailView.externalLinkView.bottomAnchor, constant: 15),
            animeDetailView.tagView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor),
            animeDetailView.tagView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor),
            animeDetailView.tagView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor),


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
    func animeDetailCharacterDataDelegate(characterData: MediaCharacterPreview, contentOffset: CGPoint) {
        if let animeDetailData = self.animeDetailData {
            let originalCharacterData = animeDetailData.characterPreview.edges
            
            var newCharacterData = originalCharacterData + characterData.data.media.characterPreview.edges
            print(newCharacterData.count)
            self.animeDetailData?.characterPreview.edges = newCharacterData
            self.animeDetailData?.characterPreview.pageInfo.currentPage = characterData.data.media.characterPreview.pageInfo.currentPage
            self.animeDetailData?.characterPreview.pageInfo.hasNextPage = characterData.data.media.characterPreview.pageInfo.hasNextPage
            
            DispatchQueue.main.async {
                var latsCharacterPreview = self.animeDetailView.characterView.characterCollectionView.subviews.last!
                self.animeDetailView.characterView.lastBottomConstraint?.isActive = false
                
                
                var tmpCharacterPreview: CharacterPreview? = latsCharacterPreview as? CharacterPreview
                for (index, edge) in characterData.data.media.characterPreview.edges.enumerated() {
                    let characterPreview = CharacterPreview()
                    characterPreview.characterImageView.loadImage(from: edge.node.image.large)
                    characterPreview.characterNameLabel.text = edge.node.name.userPreferred
                    characterPreview.characterRoleLabel.text = edge.role
                    characterPreview.voiceActorImageView.loadImage(from: edge.voiceActors.first?.image.large ?? "photo")
                    characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
                    characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
                    characterPreview.translatesAutoresizingMaskIntoConstraints = false
                    self.animeDetailView.characterView.characterCollectionView.addSubview(characterPreview)
                    
                    if index == characterData.data.media.characterPreview.edges.count - 1 { // last
                        characterPreview.topAnchor.constraint(equalTo: tmpCharacterPreview!.bottomAnchor, constant: 10).isActive = true
                        self.animeDetailView.characterView.lastBottomConstraint = characterPreview.bottomAnchor.constraint(equalTo: self.animeDetailView.characterView.characterCollectionView.bottomAnchor)
                        self.animeDetailView.characterView.lastBottomConstraint?.isActive = true
                        
                    } else { // middle
                        characterPreview.topAnchor.constraint(equalTo: tmpCharacterPreview!.bottomAnchor, constant: 10).isActive = true
                    }
                    characterPreview.leadingAnchor.constraint(equalTo: self.animeDetailView.characterView.characterCollectionView.leadingAnchor).isActive = true
                    characterPreview.widthAnchor.constraint(equalTo: self.animeDetailView.characterView.characterCollectionView.widthAnchor).isActive = true
                    characterPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
                    tmpCharacterPreview = characterPreview
                }
            }
        }
        
        
    }
    
    
    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media) {
        self.animeDetailData = media
//        print(media.streamingEpisodes)
        DispatchQueue.main.async {
//            self.animeDetailView?.setupAnimeInfoPage(animeDetailData: self.animeDetailData!)
            self.showOverviewView(sender: self.animeDetailView.animeBannerView.overviewButton)
        }
        print("load view")
    }
    
    fileprivate func setupAnimeBannerView(_ animeBannerView: AnimeBannerView, _ animeDetailData: MediaResponse.MediaData.Media) {
        animeDetailView.tmpScrollView.addSubview(animeBannerView)
        animeBannerView.animeBanner.loadImage(from: animeDetailData.bannerImage ?? "photo")
        animeBannerView.animeThumbnail.loadImage(from: animeDetailData.coverImage.extraLarge!)
        animeBannerView.animeTitleLabel.text = animeDetailData.title.native
        
        animeBannerView.overviewButton.addTarget(self, action: #selector(showOverviewView), for: .touchUpInside)
        animeBannerView.watchButton.addTarget(self, action: #selector(showWatchView), for: .touchUpInside)
        animeBannerView.charactersButton.addTarget(self, action: #selector(showCharactersView), for: .touchUpInside)
        
    }
    fileprivate func setupAnimeBannerViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.animeBannerView.topAnchor.constraint(equalTo: topAnchorView.topAnchor).isActive = true
        animeDetailView.animeBannerView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        animeDetailView.animeBannerView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor).isActive = true
        animeDetailView.animeBannerView.heightAnchor.constraint(equalToConstant: 370).isActive = true
        if isLastView {
            animeDetailView.animeBannerView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    func configureButtonsColor(sender: UIButton, buttonArr: [UIButton]) {
        for button in buttonArr {
            if button != sender {
                DispatchQueue.main.async {
                    button.setTitleColor(.blue.withAlphaComponent(0.6), for: .normal)
                    button.layer.shadowColor = .none
                    button.layer.shadowOpacity = 0
                    button.layer.shadowOffset = .zero
                    button.layer.shadowRadius = 0
                }
                
            } else {
                DispatchQueue.main.async {
                    button.setTitleColor(.blue.withAlphaComponent(0.9), for: .normal)
                    button.layer.shadowColor = UIColor.blue.cgColor
                    button.layer.shadowOpacity = 0.7
                    button.layer.shadowOffset = CGSize(width: 2, height: 5)
                    button.layer.shadowRadius = 4
                }
                
            }
        }
    }
    
    @objc func showOverviewView(sender: UIButton) {
        configureButtonsColor(sender: sender, buttonArr: [animeDetailView.animeBannerView.overviewButton, animeDetailView.animeBannerView.watchButton, animeDetailView.animeBannerView.charactersButton, animeDetailView.animeBannerView.staffButton, animeDetailView.animeBannerView.statsButton, animeDetailView.animeBannerView.socialButton])
        setupAnimeOverviewPage(animeDetailData: self.animeDetailData!)
        
    }
    
    @objc func showWatchView(sender: UIButton) {
        // banner, watchView
        configureButtonsColor(sender: sender, buttonArr: [animeDetailView.animeBannerView.overviewButton, animeDetailView.animeBannerView.watchButton, animeDetailView.animeBannerView.charactersButton, animeDetailView.animeBannerView.staffButton, animeDetailView.animeBannerView.statsButton, animeDetailView.animeBannerView.socialButton])
        setupAnimeWatchViewPage(animeDetailData: self.animeDetailData!)
    }
    
    @objc func showCharactersView(sender: UIButton) {
        configureButtonsColor(sender: sender, buttonArr: [animeDetailView.animeBannerView.overviewButton, animeDetailView.animeBannerView.watchButton, animeDetailView.animeBannerView.charactersButton, animeDetailView.animeBannerView.staffButton, animeDetailView.animeBannerView.statsButton, animeDetailView.animeBannerView.socialButton])
        setupAnimeCharatersViewPage(animeDetailData: self.animeDetailData!)
    }
    
    func setupAnimeCharatersViewPage(animeDetailData: MediaResponse.MediaData.Media) {
        for subview in animeDetailView.tmpScrollView.subviews {
            if String(describing: type(of: subview)) != "_UIScrollViewScrollIndicator" {
                subview.removeFromSuperview()
            }
        }
        let animeBannerView = animeDetailView.animeBannerView!
        let characterView = animeDetailView.characterView!
        
        setupAnimeBannerView(animeBannerView, animeDetailData)
        setupAnimeBannerViewConstraints(topAnchorView: animeDetailView.tmpScrollView, isLastView: false)
        setupAnimeCharacterView(self.animeDetailData!, characterView, canLoadMoreData: true)
        setupAnimeCharacterViewConstraints(topAnchorView: animeBannerView, isLastView: true)
    }
    
    func setupAnimeWatchViewPage(animeDetailData: MediaResponse.MediaData.Media) {
        for subview in animeDetailView.tmpScrollView.subviews {
            if String(describing: type(of: subview)) != "_UIScrollViewScrollIndicator" {
                subview.removeFromSuperview()
            }
        }
        let animeBannerView = animeDetailView.animeBannerView!
        let watchView = animeDetailView.watchView!
        
        setupAnimeBannerView(animeBannerView, animeDetailData)
        setupAnimeBannerViewConstraints(topAnchorView: animeDetailView.tmpScrollView, isLastView: false)
        setupAnimeWatchView(animeDetailData, watchView)
        setupAnimeWatchViewConstraints(topAnchorView: animeBannerView, isLastView: true)
    }
    
    fileprivate func setupAnimeInformationScrollView(_ animeInformationScrollView: AnimeInformationView, _ animeDetailData: MediaResponse.MediaData.Media) {
        animeDetailView.tmpScrollView.addSubview(animeInformationScrollView)
        if let nextAiringEpisode = animeDetailData.nextAiringEpisode {
            animeInformationScrollView.airingLabel.text =  "Ep \(nextAiringEpisode.episode): \(AnimeDetailFunc.timeLeft(from: nextAiringEpisode.airingAt))"
        } else {
            animeInformationScrollView.airingLabel.text = "FINISHED"
        }
        animeInformationScrollView.formatLabel.text = animeDetailData.format
        if let episodes = animeDetailData.episodes {
            animeInformationScrollView.episodeLabel.text = "\(episodes)"
        } else {
            animeInformationScrollView.episodeLabel.text = ""
        }
        animeInformationScrollView.episodeDurationLabel.text = "\(animeDetailData.duration) mins"
        animeInformationScrollView.statusLabel.text = animeDetailData.status
        animeInformationScrollView.startDateLabel.text = AnimeDetailFunc.startDateString(year: animeDetailData.startDate.year, month: animeDetailData.startDate.month, day: animeDetailData.startDate.day)
        animeInformationScrollView.seasonLabel.text = "\(animeDetailData.season) \(animeDetailData.seasonYear)"
        animeInformationScrollView.averageLabel.text = "\(animeDetailData.averageScore)%"
        animeInformationScrollView.meanScoreLabel.text = "\(animeDetailData.meanScore)%"
        animeInformationScrollView.popularityLabel.text = "\(animeDetailData.popularity)"
        animeInformationScrollView.favoriteLabel.text = "\(animeDetailData.favourites)"
        animeInformationScrollView.studiosLabel.text = AnimeDetailFunc.getMainStudio(from: animeDetailData.studios)
        animeInformationScrollView.producersLabel.text = AnimeDetailFunc.getProducers(from: animeDetailData.studios)
        animeInformationScrollView.sourceLabel.text = animeDetailData.source
        animeInformationScrollView.hashtagLabel.text = animeDetailData.hashtag
        animeInformationScrollView.genresLabel.text = animeDetailData.genres.joined(separator: ",")
        animeInformationScrollView.romajiLabel.text = animeDetailData.title.romaji
        animeInformationScrollView.englishLabel.text = animeDetailData.title.english
        animeInformationScrollView.nativeLabel.text = animeDetailData.title.native
        animeInformationScrollView.synonymsLabel.text = animeDetailData.synonyms.joined(separator: ",")
    }
    
    fileprivate func setupAnimeInformationScrollViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.animeInformationScrollView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 20).isActive = true
        animeDetailView.animeInformationScrollView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 10).isActive = true
        animeDetailView.animeInformationScrollView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        animeDetailView.animeInformationScrollView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor, constant: -20).isActive = true
        if isLastView {
            animeDetailView.animeInformationScrollView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeDescriptionView(_ animeDescriptionView: AnimeDescriptionView, _ animeDetailData: MediaResponse.MediaData.Media) {
        animeDetailView.tmpScrollView.addSubview(animeDescriptionView)
        animeDescriptionView.descriptionBody.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: animeDetailData.description)
    }
    fileprivate func setupAnimeDescriptionViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.animeDescriptionView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 20).isActive = true
        animeDetailView.animeDescriptionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
        animeDetailView.animeDescriptionView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor).isActive = true
        if isLastView {
            animeDetailView.animeDescriptionView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeRelationView(_ animeDetailData: MediaResponse.MediaData.Media, _ relationView: RelationView) {
        animeDetailView.tmpScrollView.addSubview(relationView)
        if let relations = animeDetailData.relations {
            var tmpRelationPreview: RelationPreview?
            for (index, edge) in relations.edges.enumerated() {
                let relationPreview = RelationPreview()
                // count == 1 set leading and trailing
                // count == 2 set leading
                // count == 3 set leading and trailing
                relationPreview.previewImage.loadImage(from: edge.node.coverImage.large)
                relationPreview.sourceLabel.text = edge.relationType
                relationPreview.titleLabel.text = edge.node.title.userPreferred
                relationPreview.typeLabel.text = edge.node.type
                relationPreview.statusLabel.text = edge.node.status
                relationPreview.translatesAutoresizingMaskIntoConstraints = false
                relationView.viewInScrollView.addSubview(relationPreview)
                relationPreview.heightAnchor.constraint(equalToConstant: 150).isActive = true
                relationPreview.widthAnchor.constraint(equalToConstant: 300).isActive = true
                
                if index != relations.edges.count - 1 && index != 0 { // middle of the scroll view
                    
                    relationPreview.leadingAnchor.constraint(equalTo: tmpRelationPreview!.trailingAnchor, constant: 30).isActive = true
                    
                    tmpRelationPreview = relationPreview
                } else if index == 0 { // first of the scroll view
                    relationPreview.leadingAnchor.constraint(equalTo: relationView.viewInScrollView.leadingAnchor).isActive = true
                    tmpRelationPreview = relationPreview
                } else { // last of the scroll view
                    relationPreview.leadingAnchor.constraint(equalTo: tmpRelationPreview!.trailingAnchor, constant: 30).isActive = true
                    relationPreview.trailingAnchor.constraint(equalTo: relationView.viewInScrollView.trailingAnchor).isActive = true
                }
                
            }
        }
    }
    fileprivate func setupAnimeRelationViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.relationView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor).isActive = true
        animeDetailView.relationView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
        animeDetailView.relationView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        animeDetailView.relationView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor).isActive = true
        animeDetailView.relationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        if isLastView {
            animeDetailView.relationView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeCharacterView(_ animeDetailData: MediaResponse.MediaData.Media, _ characterView: CharacterCollectionView, canLoadMoreData: Bool) {
        characterView.canLoadMoreData = canLoadMoreData
        for subview in characterView.characterCollectionView.subviews {
            subview.removeFromSuperview()
        }
        print(animeDetailData.characterPreview.edges.count)
        animeDetailView.tmpScrollView.addSubview(characterView)
        var tmpCharacterPreview: CharacterPreview?
        for (index, edge) in animeDetailData.characterPreview.edges.enumerated() {
            let characterPreview = CharacterPreview()
            characterPreview.characterImageView.loadImage(from: edge.node.image.large)
            characterPreview.characterNameLabel.text = edge.node.name.userPreferred
            characterPreview.characterRoleLabel.text = edge.role
            characterPreview.voiceActorImageView.loadImage(from: edge.voiceActors.first?.image.large ?? "photo")
            characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
            characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
            characterPreview.translatesAutoresizingMaskIntoConstraints = false
            characterView.characterCollectionView.addSubview(characterPreview)
            if index == 0 { // first
                characterPreview.topAnchor.constraint(equalTo: characterView.characterCollectionView.topAnchor).isActive = true
            } else if index == animeDetailData.characterPreview.edges.count - 1 { // last
                characterPreview.topAnchor.constraint(equalTo: tmpCharacterPreview!.bottomAnchor, constant: 10).isActive = true
                characterView.lastBottomConstraint = characterPreview.bottomAnchor.constraint(equalTo: characterView.characterCollectionView.bottomAnchor)
                characterView.lastBottomConstraint?.isActive = true
                
            } else { // middle
                characterPreview.topAnchor.constraint(equalTo: tmpCharacterPreview!.bottomAnchor, constant: 10).isActive = true
            }
            characterPreview.leadingAnchor.constraint(equalTo: characterView.characterCollectionView.leadingAnchor).isActive = true
//            characterPreview.trailingAnchor.constraint(equalTo: characterView.characterCollectionView.trailingAnchor).isActive = true
            characterPreview.widthAnchor.constraint(equalTo: characterView.characterCollectionView.widthAnchor).isActive = true
            characterPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
            tmpCharacterPreview = characterPreview
        }
//        if canLoadMoreData {
//            characterView.progressIndicator = UIActivityIndicatorView(style: .medium)
//            if let progressIndicator = characterView.progressIndicator {
////                progressIndicator.isHidden = true
//                progressIndicator.startAnimating()
//                progressIndicator.translatesAutoresizingMaskIntoConstraints = false
//                characterView.characterCollectionView.addSubview(progressIndicator)
//                
//                progressIndicator.topAnchor.constraint(equalTo: tmpCharacterPreview!.bottomAnchor, constant: 15).isActive = true
//                progressIndicator.bottomAnchor.constraint(equalTo: characterView.characterCollectionView.bottomAnchor, constant: -15).isActive = true
//                progressIndicator.centerXAnchor.constraint(equalTo: characterView.characterCollectionView.centerXAnchor).isActive = true
//            }
//            
//        }
    }
    fileprivate func setupAnimeCharacterViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.characterView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 10).isActive = true
        animeDetailView.characterView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
//        animeDetailView.characterView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        animeDetailView.characterView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor).isActive = true

        if isLastView {
            animeDetailView.characterView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeStaffView(_ animeDetailData: MediaResponse.MediaData.Media, _ staffView: StaffCollectionView) {
        animeDetailView.tmpScrollView.addSubview(staffView)
        var tmpStaffPreview: StaffPreview?
        for (index, edge) in animeDetailData.staffPreview.edges.enumerated() {
            let staffPreview = StaffPreview()
            staffPreview.staffImageView.loadImage(from: edge.node.image.large)
            staffPreview.staffNameLabel.text = edge.node.name.userPreferred
            staffPreview.staffRoleLabel.text = edge.role
            staffPreview.translatesAutoresizingMaskIntoConstraints = false
            staffView.staffCollectionView.addSubview(staffPreview)
            
            if index == 0 { // first
                staffPreview.topAnchor.constraint(equalTo: staffView.staffCollectionView.topAnchor).isActive = true
            } else if index == animeDetailData.staffPreview.edges.count - 1 { // last
                staffPreview.topAnchor.constraint(equalTo: tmpStaffPreview!.bottomAnchor, constant: 10).isActive = true
                staffPreview.bottomAnchor.constraint(equalTo: staffView.staffCollectionView.bottomAnchor).isActive = true
            } else { // middle
                staffPreview.topAnchor.constraint(equalTo: tmpStaffPreview!.bottomAnchor, constant: 10).isActive = true
            }
            staffPreview.leadingAnchor.constraint(equalTo: staffView.staffCollectionView.leadingAnchor).isActive = true
            staffPreview.trailingAnchor.constraint(equalTo: staffView.staffCollectionView.trailingAnchor).isActive = true
            staffPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
            tmpStaffPreview = staffPreview
        }
    }
    fileprivate func setupAnimeStaffViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.staffView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 10).isActive = true
        animeDetailView.staffView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
        animeDetailView.staffView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        if isLastView {
            animeDetailView.staffView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeStatusDistributionView(_ animeDetailData: MediaResponse.MediaData.Media, _ statusDistributionView: StatusDistributionView) {
        animeDetailView.tmpScrollView.addSubview(statusDistributionView)
        let statusDistribution = animeDetailData.stats.statusDistribution.sorted(by: {$0.amount > $1.amount})
        let totalAmount = statusDistribution.reduce(0) { (result, statusDistribution) -> Int in
            return result + statusDistribution.amount
        }
        let statusDistributionStatusLabel = [statusDistributionView.firstTextLabel, statusDistributionView.secondTextLabel, statusDistributionView.thirdTextLabel, statusDistributionView.fourthTextLabel, statusDistributionView.fifthTextLabel]
        let statusDistributionAmountLabel = [statusDistributionView.firstUsersLabel, statusDistributionView.secondUsersLabel, statusDistributionView.thirdUsersLabel, statusDistributionView.fourthUsersLabel, statusDistributionView.fifthUsersLabel]
        let statsColor: [UIColor] = [#colorLiteral(red: 0.4110881686, green: 0.8372716904, blue: 0.2253350019, alpha: 1), #colorLiteral(red: 0.00486722542, green: 0.6609873176, blue: 0.9997979999, alpha: 1), #colorLiteral(red: 0.5738196373, green: 0.3378910422, blue: 0.9544720054, alpha: 1), #colorLiteral(red: 0.9687278867, green: 0.4746391773, blue: 0.6418368816, alpha: 1), #colorLiteral(red: 0.9119635224, green: 0.3648597598, blue: 0.4597702026, alpha: 1)]
        var buttonConf = UIButton.Configuration.filled()
        buttonConf.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        for (index, label) in statusDistributionStatusLabel.enumerated() {
            buttonConf.baseBackgroundColor = statsColor[index]
            buttonConf.baseForegroundColor = .white
            buttonConf.title = statusDistribution[index].status.uppercased()
            label?.configuration = buttonConf
        }
        for (index, label) in statusDistributionAmountLabel.enumerated() {
            label?.text = "\(statusDistribution[index].amount)"
            label?.adjustsFontSizeToFitWidth = true
        }
        var lastView: UIView = statusDistributionView.persentView
        for (index, status) in statusDistribution.enumerated() {
            let tmpView = UIView()
            tmpView.backgroundColor = statsColor[index]
            tmpView.translatesAutoresizingMaskIntoConstraints = false
            statusDistributionView.persentView.addSubview(tmpView)
            tmpView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            tmpView.bottomAnchor.constraint(equalTo: statusDistributionView.persentView.bottomAnchor).isActive = true
            //            print(CGFloat(status.amount) / CGFloat(totalAmount) * statusDistributionView.persentView.bounds.size.width)
            if index != statusDistribution.count - 1 && index != 0 {
                
                tmpView.widthAnchor.constraint(equalTo: statusDistributionView.persentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmount)).isActive = true
                tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
            } else if index == 0 {
                tmpView.leadingAnchor.constraint(equalTo: lastView.leadingAnchor).isActive = true
                tmpView.widthAnchor.constraint(equalTo: statusDistributionView.persentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmount)).isActive = true
            } else {
                tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                tmpView.trailingAnchor.constraint(equalTo: statusDistributionView.persentView.trailingAnchor).isActive = true
            }
            lastView = tmpView
        }
    }
    fileprivate func setupAnimeStatusDistributionViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.statusDistributionView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 20).isActive = true
        animeDetailView.statusDistributionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 5).isActive = true
        animeDetailView.statusDistributionView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor, constant: -5).isActive = true
        if isLastView {
            animeDetailView.statusDistributionView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeScoreDistributionView(_ animeDetailData: MediaResponse.MediaData.Media, _ scoreDistributionView: ScoreDistributionView) {
        animeDetailView.tmpScrollView.addSubview(scoreDistributionView)
        let scoreAmountTotal = animeDetailData.stats.scoreDistribution.reduce(0) { ( result, scoreDistribution) -> Int in
            return result + scoreDistribution.amount
        }
        var tmpScoreView: UIView?
        for (index, score) in animeDetailData.stats.scoreDistribution.enumerated() {
            let percent = AnimeDetailFunc.partOfAmount(value: score.amount, totalValue: scoreAmountTotal)
            let scoreView = UIView()
            scoreView.layer.cornerRadius = 5
            scoreView.clipsToBounds = true
            // 0 1 2 3 4(yellow) | 5 6 7 8 9
            if index < 5 {
                scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemRed, color2: UIColor.systemYellow, fraction: CGFloat(index) / 5)
            } else {
                scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemYellow, color2: UIColor.systemGreen, fraction: CGFloat(index - 4) / 5)
            }
            
            scoreDistributionView.contentViewInScoreView.addSubview(scoreView)
            scoreView.translatesAutoresizingMaskIntoConstraints = false
            scoreView.bottomAnchor.constraint(equalTo: scoreDistributionView.contentViewInScoreView.bottomAnchor, constant: -40).isActive = true
            scoreView.heightAnchor.constraint(equalToConstant: 100 * percent + 10).isActive = true
            scoreView.widthAnchor.constraint(equalToConstant: 25).isActive = true
            if index == 0 {
                scoreView.leadingAnchor.constraint(equalTo: scoreDistributionView.contentViewInScoreView.leadingAnchor, constant: 15).isActive = true
            } else if index == animeDetailData.stats.scoreDistribution.count - 1 {
                scoreView.leadingAnchor.constraint(equalTo: tmpScoreView!.trailingAnchor, constant: 30).isActive = true
                scoreView.trailingAnchor.constraint(equalTo: scoreDistributionView.contentViewInScoreView.trailingAnchor, constant: -15).isActive = true
            } else {
                scoreView.leadingAnchor.constraint(equalTo: tmpScoreView!.trailingAnchor, constant: 30).isActive = true
            }
            tmpScoreView = scoreView
            let percentLabel = UILabel()
            percentLabel.adjustsFontSizeToFitWidth = true
            percentLabel.translatesAutoresizingMaskIntoConstraints = false
            percentLabel.text = String(format: "%.1f%%", percent * 100)
            scoreDistributionView.contentViewInScoreView.addSubview(percentLabel)
            percentLabel.bottomAnchor.constraint(equalTo: scoreView.topAnchor, constant: -10).isActive = true
            percentLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
            percentLabel.centerXAnchor.constraint(equalTo: scoreView.centerXAnchor).isActive = true
            
            let scoreLabel = UILabel()
            scoreLabel.translatesAutoresizingMaskIntoConstraints = false
            scoreLabel.textAlignment = .center
            scoreLabel.text = "\(score.score)"
            scoreLabel.textColor = .secondaryLabel
            scoreDistributionView.contentViewInScoreView.addSubview(scoreLabel)
            scoreLabel.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 5).isActive = true
            scoreLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
            scoreLabel.centerXAnchor.constraint(equalTo: scoreView.centerXAnchor).isActive = true
        }
    }
    fileprivate func setupAnimeScoreDistributionViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.scoreDistributionView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 15).isActive = true
        animeDetailView.scoreDistributionView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
        animeDetailView.scoreDistributionView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        animeDetailView.scoreDistributionView.heightAnchor.constraint(equalToConstant: 175).isActive = true
        if isLastView {
            animeDetailView.scoreDistributionView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeWatchView(_ animeDetailData: MediaResponse.MediaData.Media, _ watchView: AnimeWatchPreviewContainer) {
        animeDetailView.tmpScrollView.addSubview(watchView)
        var tmpStreamingPreview: AnimeWatchPreview?
        for (index, streaming) in animeDetailData.streamingEpisodes.enumerated() {
            let watchPreview = AnimeWatchPreview()
            watchPreview.animeWatchPreviewImageView.loadImage(from: streaming.thumbnail)
            watchPreview.animeWatchPreviewLabel.text = streaming.title
            watchPreview.translatesAutoresizingMaskIntoConstraints = false
            watchView.viewInScrollView.addSubview(watchPreview)
            
            watchPreview.heightAnchor.constraint(equalToConstant: 128).isActive = true
            watchPreview.widthAnchor.constraint(equalToConstant: 300).isActive = true
            // 0 1 2 3
            if index == 0 {
                watchPreview.leadingAnchor.constraint(equalTo: watchView.viewInScrollView.leadingAnchor).isActive = true
                if animeDetailData.streamingEpisodes.count == 1 {
                    watchPreview.trailingAnchor.constraint(equalTo: watchView.viewInScrollView.trailingAnchor).isActive = true
                }
            }else if index == animeDetailData.streamingEpisodes.count - 1 {
                watchPreview.trailingAnchor.constraint(equalTo: watchView.viewInScrollView.trailingAnchor).isActive = true
                if let tmpStreamingPreview = tmpStreamingPreview {
                    watchPreview.leadingAnchor.constraint(equalTo: tmpStreamingPreview.trailingAnchor, constant: 20).isActive = true
                }
            } else {
                watchPreview.leadingAnchor.constraint(equalTo: tmpStreamingPreview!.trailingAnchor, constant: 20).isActive = true
            }
            tmpStreamingPreview = watchPreview
        }
    }
    fileprivate func setupAnimeWatchViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.watchView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 15).isActive = true
        animeDetailView.watchView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
//        animeDetailView.watchView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        animeDetailView.watchView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor).isActive = true
        if isLastView {
            animeDetailView.watchView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeRecommendationsView(_ animeDetailData: MediaResponse.MediaData.Media, _ recommendationsView: RecommendationsView) {
        animeDetailView.tmpScrollView.addSubview(recommendationsView)
        var tmpRecommendationsPreview: RecommendationsAnimePreview?
        for (index, recommendation) in animeDetailData.recommendations.nodes.enumerated() {
            let recommendationsPreview = RecommendationsAnimePreview()
            recommendationsPreview.translatesAutoresizingMaskIntoConstraints = false
            recommendationsPreview.animeTitle.text = recommendation.mediaRecommendation?.title.userPreferred
            if let coverImage = recommendation.mediaRecommendation?.coverImage?.large {
                recommendationsPreview.coverImageView.loadImage(from: coverImage)
            } else {
                recommendationsPreview.coverImageView.image = UIImage(systemName: "photo")
            }
            recommendationsView.viewInScrollView.addSubview(recommendationsPreview)
            
            recommendationsPreview.topAnchor.constraint(equalTo: recommendationsView.viewInScrollView.topAnchor).isActive = true
            recommendationsPreview.heightAnchor.constraint(equalTo: recommendationsView.viewInScrollView.heightAnchor).isActive = true
            
            if index == 0 {
                recommendationsPreview.leadingAnchor.constraint(equalTo: recommendationsView.viewInScrollView.leadingAnchor).isActive = true
                
            } else if index == animeDetailData.recommendations.nodes.count - 1 {
                recommendationsPreview.trailingAnchor.constraint(equalTo: recommendationsView.viewInScrollView.trailingAnchor, constant: -20).isActive = true
                if let tmpRecommendationsPreview = tmpRecommendationsPreview {
                    recommendationsPreview.leadingAnchor.constraint(equalTo: tmpRecommendationsPreview.trailingAnchor, constant: 20).isActive = true
                }
            } else {
                recommendationsPreview.leadingAnchor.constraint(equalTo: tmpRecommendationsPreview!.trailingAnchor, constant: 20).isActive = true
            }
            tmpRecommendationsPreview = recommendationsPreview
        }
    }
    fileprivate func setupAnimeRecommendationsViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.recommendationsView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 15).isActive = true
        animeDetailView.recommendationsView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 5).isActive = true
        animeDetailView.recommendationsView.widthAnchor.constraint(equalTo: animeDetailView.tmpScrollView.widthAnchor, constant: -5).isActive = true
//        animeDetailView.recommendationsView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        if isLastView {
            animeDetailView.recommendationsView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeReviewView(_ animeDetailData: MediaResponse.MediaData.Media, _ reviewView: ReviewsView) {
        animeDetailView.tmpScrollView.addSubview(reviewView)
        var tmpAnimeReview: AnimeReview?
        if animeDetailData.reviewPreview.nodes.count == 0 {
            let voidLabel = UILabel()
            voidLabel.backgroundColor = .white
            voidLabel.text = "This anime didn't have review yet"
            voidLabel.font = .italicSystemFont(ofSize: 15)
            voidLabel.textColor = UIColor.secondaryLabel
            voidLabel.translatesAutoresizingMaskIntoConstraints = false
            reviewView.reviewContainer.addSubview(voidLabel)
            voidLabel.topAnchor.constraint(equalTo: reviewView.reviewContainer.topAnchor).isActive = true
            voidLabel.leadingAnchor.constraint(equalTo: reviewView.reviewContainer.leadingAnchor).isActive = true
            voidLabel.trailingAnchor.constraint(equalTo: reviewView.reviewContainer.trailingAnchor).isActive = true
            voidLabel.bottomAnchor.constraint(equalTo: reviewView.reviewContainer.bottomAnchor).isActive = true
            voidLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
        } else {
            for (index, review) in animeDetailData.reviewPreview.nodes.enumerated() {
                let animeReview = AnimeReview()
                animeReview.userReviewLabel.layer.cornerRadius = 10
                animeReview.userReviewLabel.clipsToBounds = true
                animeReview.userAvatar.loadImage(from: review.user.avatar?.large)
                animeReview.userReviewLabel.text = review.summary
                animeReview.translatesAutoresizingMaskIntoConstraints = false
                reviewView.reviewContainer.addSubview(animeReview)
                
                animeReview.leadingAnchor.constraint(equalTo: reviewView.reviewContainer.leadingAnchor).isActive = true
                animeReview.trailingAnchor.constraint(equalTo: reviewView.reviewContainer.trailingAnchor).isActive = true
                if index == 0 {
                    animeReview.topAnchor.constraint(equalTo: reviewView.reviewContainer.topAnchor).isActive = true
                } else if index == animeDetailData.reviewPreview.nodes.count - 1 {
                    animeReview.bottomAnchor.constraint(equalTo: reviewView.reviewContainer.bottomAnchor).isActive = true
                    if let tmpAnimeReview = tmpAnimeReview {
                        animeReview.topAnchor.constraint(equalTo: tmpAnimeReview.bottomAnchor, constant: 20).isActive = true
                    }
                } else {
                    animeReview.topAnchor.constraint(equalTo: tmpAnimeReview!.bottomAnchor, constant: 20).isActive = true
                }
                tmpAnimeReview = animeReview
            }
        }
    }
    fileprivate func setupAnimeReviewViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.reviewView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 15).isActive = true
        animeDetailView.reviewView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor, constant: 5).isActive = true
        animeDetailView.reviewView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor, constant: -5).isActive = true
        if isLastView {
            animeDetailView.reviewView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeExternalLinkView(_ animeDetailData: MediaResponse.MediaData.Media, _ externalLinkView: ExternalLinkView) {
        animeDetailView.tmpScrollView.addSubview(externalLinkView)
        var tmpExternalLinkPreview: ExternalLinkPreview?
        for (index, externalLink) in animeDetailData.externalLinks.enumerated() {
            let externalLinkPreview = ExternalLinkPreview()
            externalLinkPreview.translatesAutoresizingMaskIntoConstraints = false
            if let externalLinkIcon = externalLink.icon {
                externalLinkPreview.externalLinkIcon.loadImage(from: externalLinkIcon)
            } else {
                externalLinkPreview.externalLinkIcon.image = UIImage(systemName: "link")
            }
            externalLinkPreview.externalLinkIcon.backgroundColor = UIColor(hex: externalLink.color)
            externalLinkPreview.externalLinkIconColor.backgroundColor = UIColor(hex: externalLink.color)
            externalLinkPreview.externalLinkIconColor.layer.cornerRadius = 10
            externalLinkPreview.externalLinkIconColor.clipsToBounds = true
            externalLinkPreview.externalLinkTitle.text = externalLink.site
            //            externalLinkPreview.externalLinkTitle.textColor = .secondaryLabel
            externalLinkPreview.externalLinkTitleNote.text = externalLink.notes == nil ? "" : "(\(externalLink.notes!))"
            externalLinkPreview.externalLinkTitleNote.textColor = .secondaryLabel
            externalLinkPreview.layer.cornerRadius = 10
            externalLinkPreview.clipsToBounds = true
            externalLinkView.linkContainer.addSubview(externalLinkPreview)
            
            externalLinkPreview.leadingAnchor.constraint(equalTo: externalLinkView.linkContainer.leadingAnchor).isActive = true
            externalLinkPreview.trailingAnchor.constraint(equalTo: externalLinkView.linkContainer.trailingAnchor).isActive = true
            if index == 0 {
                externalLinkPreview.topAnchor.constraint(equalTo: externalLinkView.linkContainer.topAnchor).isActive = true
            } else if index == animeDetailData.externalLinks.count - 1 {
                externalLinkPreview.bottomAnchor.constraint(equalTo: externalLinkView.linkContainer.bottomAnchor).isActive = true
                if let tmpExternalLinkPreview = tmpExternalLinkPreview {
                    externalLinkPreview.topAnchor.constraint(equalTo: tmpExternalLinkPreview.bottomAnchor, constant: 10).isActive = true
                }
            } else {
                externalLinkPreview.topAnchor.constraint(equalTo: tmpExternalLinkPreview!.bottomAnchor, constant: 10).isActive = true
            }
            tmpExternalLinkPreview = externalLinkPreview
        }
    }
    fileprivate func setupAnimeExternalLinkViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.externalLinkView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 15).isActive = true
        animeDetailView.externalLinkView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
        animeDetailView.externalLinkView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        if isLastView {
            animeDetailView.externalLinkView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    fileprivate func setupAnimeTagView(_ animeDetailData: MediaResponse.MediaData.Media, _ tagView: TagView) {
        animeDetailView.tmpScrollView.addSubview(tagView)
        var tmpTagPreview: TagPreview?
        for (index, tag) in animeDetailData.tags.enumerated() {
            let tagPreview = TagPreview()
            tagPreview.tagName.text = tag.name
            tagPreview.tagPercent.text = "\(tag.rank) %"
            tagPreview.isHidden = tag.isMediaSpoiler
            tagPreview.translatesAutoresizingMaskIntoConstraints = false
            tagView.tagsContainer.addSubview(tagPreview)
            
            tagPreview.leadingAnchor.constraint(equalTo: tagView.tagsContainer.leadingAnchor).isActive = true
            tagPreview.trailingAnchor.constraint(equalTo: tagView.tagsContainer.trailingAnchor).isActive = true
            tagPreview.heightAnchor.constraint(equalToConstant: 40).isActive = true
            if index == 0 {
                tagPreview.topAnchor.constraint(equalTo: tagView.tagsContainer.topAnchor).isActive = true
            } else if index == animeDetailData.tags.count - 1 {
                tagPreview.bottomAnchor.constraint(equalTo: tagView.tagsContainer.bottomAnchor).isActive = true
                if let tmpTagPreview = tmpTagPreview {
                    tagPreview.topAnchor.constraint(equalTo: tmpTagPreview.bottomAnchor, constant: 10).isActive = true
                }
            } else {
                tagPreview.topAnchor.constraint(equalTo: tmpTagPreview!.bottomAnchor, constant: 10).isActive = true
            }
            tmpTagPreview = tagPreview
        }
    }
    fileprivate func setupAnimeTagViewConstraints(topAnchorView: UIView, isLastView: Bool) {
        animeDetailView.tagView.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor, constant: 15).isActive = true
        animeDetailView.tagView.leadingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.leadingAnchor).isActive = true
        animeDetailView.tagView.trailingAnchor.constraint(equalTo: animeDetailView.tmpScrollView.trailingAnchor).isActive = true
        animeDetailView.tagView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        if isLastView {
            animeDetailView.tagView.bottomAnchor.constraint(equalTo: animeDetailView.tmpScrollView.bottomAnchor).isActive = true
        }
    }
    
    func setupAnimeOverviewPage(animeDetailData: MediaResponse.MediaData.Media) {
        for subview in animeDetailView.tmpScrollView.subviews {
            if String(describing: type(of: subview)) != "_UIScrollViewScrollIndicator" {
                subview.removeFromSuperview()
            }
        }
        let animeBannerView = animeDetailView.animeBannerView!
        let animeInformationScrollView = animeDetailView.animeInformationScrollView!
        let animeDescriptionView = animeDetailView.animeDescriptionView!
        let relationView = animeDetailView.relationView!
        let characterView = animeDetailView.characterView!
        let staffView = animeDetailView.staffView!
        let statusDistributionView = animeDetailView.statusDistributionView!
        let scoreDistributionView = animeDetailView.scoreDistributionView!
        let watchView = animeDetailView.watchView!
        let recommendationsView = animeDetailView.recommendationsView!
        let reviewView = animeDetailView.reviewView!
        let externalLinkView = animeDetailView.externalLinkView!
        let tagView = animeDetailView.tagView!
        
        animeDetailView.tmpScrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        animeDetailView.tmpScrollView.leadingAnchor.constraint(equalTo: animeDetailView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        animeDetailView.tmpScrollView.trailingAnchor.constraint(equalTo: animeDetailView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        animeDetailView.tmpScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        setupAnimeBannerView(animeBannerView, animeDetailData)
        setupAnimeBannerViewConstraints(topAnchorView: animeDetailView.tmpScrollView, isLastView: false)
        
        setupAnimeInformationScrollView(animeInformationScrollView, animeDetailData)
        setupAnimeInformationScrollViewConstraints(topAnchorView: animeBannerView, isLastView: false)
        
        setupAnimeDescriptionView(animeDescriptionView, animeDetailData)
        setupAnimeDescriptionViewConstraints(topAnchorView: animeInformationScrollView, isLastView: false)
        
        setupAnimeRelationView(animeDetailData, relationView)
        setupAnimeRelationViewConstraints(topAnchorView: animeDescriptionView, isLastView: false)
        
        setupAnimeCharacterView(animeDetailData, characterView, canLoadMoreData: false)
        setupAnimeCharacterViewConstraints(topAnchorView: relationView, isLastView: false)
        
        setupAnimeStaffView(animeDetailData, staffView)
        setupAnimeStaffViewConstraints(topAnchorView: characterView, isLastView: false)
        
        setupAnimeStatusDistributionView(animeDetailData, statusDistributionView)
        setupAnimeStatusDistributionViewConstraints(topAnchorView: staffView, isLastView: false)
        
        setupAnimeScoreDistributionView(animeDetailData, scoreDistributionView)
        setupAnimeScoreDistributionViewConstraints(topAnchorView: statusDistributionView, isLastView: false)
        
        setupAnimeWatchView(animeDetailData, watchView)
        setupAnimeWatchViewConstraints(topAnchorView: scoreDistributionView, isLastView: false)
        
        setupAnimeRecommendationsView(animeDetailData, recommendationsView)
        setupAnimeRecommendationsViewConstraints(topAnchorView: watchView, isLastView: false)
        
        setupAnimeReviewView(animeDetailData, reviewView)
        setupAnimeReviewViewConstraints(topAnchorView: recommendationsView, isLastView: false)
        
        setupAnimeExternalLinkView(animeDetailData, externalLinkView)
        setupAnimeExternalLinkViewConstraints(topAnchorView: reviewView, isLastView: false)
        
        setupAnimeTagView(animeDetailData, tagView)
        setupAnimeTagViewConstraints(topAnchorView: externalLinkView, isLastView: true)
        
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

extension AnimeDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("scroll")
        if scrollView == animeDetailView.tmpScrollView {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            if let canLoadMoreData = animeDetailView.characterView.canLoadMoreData {
//                print("go in")
                if offsetY > contentHeight - frameHeight {
                    if animeDetailData!.characterPreview.pageInfo.hasNextPage && !animeFetchingDataManager.isFetchingData {
                        let contentOffset = scrollView.contentOffset
                        print("fetch data")
//                        animeDetailView.characterView.progressIndicator?.isHidden = false
//                        animeDetailView.characterView.progressIndicator?.startAnimating()
                        animeFetchingDataManager.fetchCharacterPreviewByMediaId(id: animeDetailData!.id, page: animeDetailData!.characterPreview.pageInfo.currentPage + 1, contentOffset: contentOffset)
//                        animeDetailView.characterView.removeConstraints(animeDetailView.characterView.constraints)
                        
                        
//                        DispatchQueue.main.async {
//                            self.setupAnimeCharacterView(self.animeDetailData!, self.animeDetailView.characterView, canLoadMoreData: true)
//                            self.animeDetailView.characterView.progressIndicator?.isHidden = true
//                        }
//                        self.setupAnimeCharacterView(self.animeDetailData!, self.animeDetailView.characterView, canLoadMoreData: true)
                    }
                    
                }
            }
            
        }
        
    }
}
