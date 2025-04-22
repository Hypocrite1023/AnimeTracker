//
//  AnimeDetailView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/19.
//

import UIKit

class AnimeDetailView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // overview, watch, characters, staff, reviews(不是每個都有), stats, social
    var tmpScrollView: UIScrollView! // all
    
    var animeBannerView: AnimeBannerView! {
        didSet {
            animeBannerView.translatesAutoresizingMaskIntoConstraints = false
        }
    }// all
    var animeInformationScrollView: AnimeInformationView! // overview
    var animeDescriptionView: AnimeDescriptionView! // overview
    var relationView: RelationView! // overview
    var characterView: CharacterCollectionView! // overview, characters
    var staffView: StaffCollectionView! // overview, staff
    var statusDistributionView: StatusDistributionView! // overview, stats
    var scoreDistributionView: ScoreDistributionView! // overview, stats
    var watchView: AnimeWatchPreviewContainer! // overview, watch
    var recommendationsView: RecommendationsView! // overview
    var reviewView: ReviewsView! // overview, reviews
    var externalLinkView: ExternalLinkView! // overview
    var tagView: TagView! // overview
    var rankingView: RankingView? {
        didSet {
            rankingView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    var threadView: ThreadsView? {
        didSet {
            threadView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
        
    var differentViewContainer: UIView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = .white
        
        setupAnimeInfoPage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAnimeInfoPage() {
        
        
        tmpScrollView = UIScrollView()
        tmpScrollView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.backgroundColor = #colorLiteral(red: 0.9306586385, green: 0.9455893636, blue: 0.9625305533, alpha: 1)
        tmpScrollView.backgroundColor = .clear
        self.addSubview(tmpScrollView)
        
        animeBannerView = AnimeBannerView()
//        animeBannerView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(animeBannerView)
        
        
        animeInformationScrollView = AnimeInformationView()
        animeInformationScrollView.airingLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        animeInformationScrollView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(animeInformationScrollView)
        
        animeDescriptionView = AnimeDescriptionView()
        animeDescriptionView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(animeDescriptionView)
        
        relationView = RelationView()
        relationView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(relationView)
        
        characterView = CharacterCollectionView()
        characterView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(characterView)
        
        staffView = StaffCollectionView()
        staffView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(staffView)
        
        statusDistributionView = StatusDistributionView()
        statusDistributionView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(statusDistributionView)
        
        scoreDistributionView = ScoreDistributionView()
        scoreDistributionView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(scoreDistributionView)
        
        watchView = AnimeWatchPreviewContainer()
        watchView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(watchView)
        
        recommendationsView = RecommendationsView()
        recommendationsView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(recommendationsView)
        
        reviewView = ReviewsView()
        reviewView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(reviewView)
        
        externalLinkView = ExternalLinkView()
        externalLinkView.translatesAutoresizingMaskIntoConstraints = false
//        tmpScrollView.addSubview(externalLinkView)
        
        tagView = TagView()
        tagView.translatesAutoresizingMaskIntoConstraints = false
        
    }
    deinit {
        print("AnimeDetailView deinit")
    }

}
