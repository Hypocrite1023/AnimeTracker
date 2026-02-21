//
//  AnimeReview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit

class AnimeReview: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userReviewLabelBackGround: UIView!
    @IBOutlet weak var userReviewLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AnimeReview", owner: self, options: nil)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setStyle()
    }
    
    func bind(_ model: Model) {
        userAvatar.kf.setImage(with: model.userAvatarURL)
        userReviewLabel.text = model.userReview
    }
    
    private func setStyle() {
        userAvatar.layer.cornerRadius = 20
        userAvatar.clipsToBounds = true
        
        userReviewLabel.font = .atBody
        userReviewLabel.textColor = .atTextPrimary
        userReviewLabel.textAlignment = .left
        userReviewLabel.backgroundColor = .clear
        userReviewLabel.numberOfLines = 0
        
        userReviewLabelBackGround.backgroundColor = .atSecondaryBackground
        userReviewLabelBackGround.layer.cornerRadius = 8
        userReviewLabelBackGround.clipsToBounds = true
    }
    
    struct Model {
        let userAvatarURL: URL?
        let userReview: String?
    }
}
