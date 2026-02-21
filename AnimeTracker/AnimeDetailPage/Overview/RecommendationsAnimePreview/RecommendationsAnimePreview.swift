//
//  RecommendationsAnimePreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit
import Combine

class RecommendationsAnimePreview: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    
    var animeID: Int?
    
    private(set) var recommendationAnimeTapSubject: PassthroughSubject<Int?, Never> = .init()
    
    weak var recommendationDelegate: RecommendationDelegate?
    
    init(frame: CGRect, animeID: Int?) {
        self.animeID = animeID
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
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
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let recommendationTapGesture = UITapGestureRecognizer(target: self, action: #selector(loadRecommendation))
        self.addGestureRecognizer(recommendationTapGesture)
        setStyle()
    }
    
    func bind(_ model: Model) {
        animeID = model.animeID
        animeTitle.text = model.animeTitle
        coverImageView.kf.setImage(with: model.animeThumbnailURL)
    }
    
    private func setStyle() {
        coverImageView.contentMode = .scaleAspectFill
        animeTitle.font = .atCaption
        animeTitle.textColor = .atTextPrimary
        backgroundColor = .atSecondaryBackground
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    @objc func loadRecommendation(sender: UIGestureRecognizer) {
        recommendationAnimeTapSubject.send(animeID)
    }
}

extension RecommendationsAnimePreview {
    struct Model {
        let animeID: Int?
        let animeThumbnailURL: URL?
        let animeTitle: String?
    }
}

protocol RecommendationDelegate: AnyObject {
    func passRecommendationAnimeID(_ id: Int)
}
