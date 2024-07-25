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
        
    }
    
    

}
