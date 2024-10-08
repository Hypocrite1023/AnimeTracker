//
//  RecommendationsAnimePreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit

class RecommendationsAnimePreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    
    let animeID: Int?
    weak var animeDataFetcher: FetchAnimeDetailDataByID?
    
    init(frame: CGRect, animeID: Int?) {
        self.animeID = animeID
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.animeID = nil
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("RecommendationsAnimePreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let recommendationTapGesture = AnimeRecommendationTapGesture(target: self, action: #selector(loadRecommendation), animeID: self.animeID)
        self.addGestureRecognizer(recommendationTapGesture)
    }

    @objc func loadRecommendation(sender: AnimeRecommendationTapGesture) {
        if let animeID = sender.animeID {
            animeDataFetcher?.passAnimeID(animeID: animeID)
        }
    }
}

class AnimeRecommendationTapGesture: UITapGestureRecognizer {
    let animeID: Int?
    init(target: Any?, action: Selector?, animeID: Int?) {
        self.animeID = animeID
        super.init(target: target, action: action)
    }
}
