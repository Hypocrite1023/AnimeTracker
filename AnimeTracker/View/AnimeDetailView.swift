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
    var tmpScrollView: UIScrollView!
    
    var animeBannerView: AnimeBannerView!
    
    // 460 * 650
    // add to list
    // heart button
    var animeInformationScrollView: AnimeInformationView!
    var animeDescriptionView: AnimeDescriptionView!
    var relationView: RelationView!
    var characterView: CharacterCollectionView!
    var staffView: StaffCollectionView!
    var statusDistributionView: StatusDistributionView!
    var scoreDistributionView: ScoreDistributionView!
    var watchView: AnimeWatchPreviewContainer!
    var recommendationsView: RecommendationsView!
    var reviewView: ReviewsView!
    var externalLinkView: ExternalLinkView!
    var tagView: TagView!
        
    var differentViewContainer: UIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupAnimeInfoPage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAnimeInfoPage() {
        
        
        tmpScrollView = UIScrollView()
        tmpScrollView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.backgroundColor = #colorLiteral(red: 0.9306586385, green: 0.9455893636, blue: 0.9625305533, alpha: 1)
        self.addSubview(tmpScrollView)
        
        animeBannerView = AnimeBannerView()
        animeBannerView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(animeBannerView)
        
        
        animeInformationScrollView = AnimeInformationView()
        animeInformationScrollView.airingLabel.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        animeInformationScrollView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(animeInformationScrollView)
        
        animeDescriptionView = AnimeDescriptionView()
        animeDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(animeDescriptionView)
        
        relationView = RelationView()
        relationView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(relationView)
        
        characterView = CharacterCollectionView()
        characterView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(characterView)
        
        staffView = StaffCollectionView()
        staffView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(staffView)
        
        statusDistributionView = StatusDistributionView()
        statusDistributionView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(statusDistributionView)
        
        scoreDistributionView = ScoreDistributionView()
        scoreDistributionView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(scoreDistributionView)
        
        watchView = AnimeWatchPreviewContainer()
        watchView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(watchView)
        
        recommendationsView = RecommendationsView()
        recommendationsView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(recommendationsView)
        
        reviewView = ReviewsView()
        reviewView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(reviewView)
        
        externalLinkView = ExternalLinkView()
        externalLinkView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(externalLinkView)
        
        tagView = TagView()
        tagView.translatesAutoresizingMaskIntoConstraints = false
        tmpScrollView.addSubview(tagView)
        
    }
    
    func setupAnimeInfoPage(animeDetailData: MediaResponse.MediaData.Media) {
        animeBannerView.animeBanner.loadImage(from: animeDetailData.bannerImage ?? "photo")
        animeBannerView.animeThumbnail.loadImage(from: animeDetailData.coverImage.extraLarge!)
        animeBannerView.animeTitleLabel.text = animeDetailData.title.native
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
        animeDescriptionView.descriptionBody.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: animeDetailData.description)
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
                characterPreview.bottomAnchor.constraint(equalTo: characterView.characterCollectionView.bottomAnchor).isActive = true
            } else { // middle
                characterPreview.topAnchor.constraint(equalTo: tmpCharacterPreview!.bottomAnchor, constant: 10).isActive = true
            }
            characterPreview.leadingAnchor.constraint(equalTo: characterView.characterCollectionView.leadingAnchor).isActive = true
            characterPreview.trailingAnchor.constraint(equalTo: characterView.characterCollectionView.trailingAnchor).isActive = true
            characterPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
            tmpCharacterPreview = characterPreview
        }
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
            print(CGFloat(index) / 5)
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
    
    

}
