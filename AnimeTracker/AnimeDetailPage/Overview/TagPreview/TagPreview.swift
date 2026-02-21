//
//  TagPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit
import Combine

class TagPreview: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagPercent: UILabel!
    @IBOutlet weak var tagInfoButton: UIButton!
    
    private(set) var tagInfoTapSubject: PassthroughSubject<String, Never> = .init()
    private var infoBtnTapCancellable: Set<AnyCancellable> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("TagPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.cornerRadius = 8
        clipsToBounds = true
        tagInfoButton.tintColor = .atTextLink
    }
    
    func bind(_ model: Model) {
        tagName.text = model.tagName
        if let tagPercentValue = model.rank {
            tagPercent.text = "\(tagPercentValue)%"
        } else {
            tagPercent.isHidden = true
        }
        if let isMediaSpoiler = model.isMediaSpoiler, isMediaSpoiler {
            let blurEffect = UIBlurEffect(style: .light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            addSubview(blurEffectView)
            blurEffectView.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
            let eyeSlashImg = UIImageView(image: UIImage(systemName: "eye.slash.fill"))
            eyeSlashImg.tintColor = .secondaryLabel
            let spoilerText = UILabel()
            spoilerText.text = "Spoiler Tag"
            spoilerText.textColor = .secondaryLabel
            spoilerText.font = .atSubheadline
            spoilerText.textColor = .atTextSecondary
            let spoilerTemplateView = UIStackView(arrangedSubviews: [eyeSlashImg, spoilerText])
            spoilerTemplateView.axis = .horizontal
            spoilerTemplateView.spacing = 10
            blurEffectView.contentView.addSubview(spoilerTemplateView)
            spoilerTemplateView.snp.makeConstraints { make in
                make.centerX.centerY.equalTo(blurEffectView.contentView)
            }
            
            let tapToShow = UITapGestureRecognizer(target: self, action: #selector(showSpoiler))
            blurEffectView.addGestureRecognizer(tapToShow)
        }
        
        tagInfoButton.tapPublisher
            .compactMap { _ in model.tagDescription }
            .subscribe(tagInfoTapSubject)
            .store(in: &infoBtnTapCancellable)
    }
    
    @objc func showSpoiler() {
        subviews.first(where: { $0 is UIVisualEffectView })?.removeFromSuperview()
    }
}

extension TagPreview {
    struct Model {
        let tagName: String?
        let tagDescription: String?
        let isMediaSpoiler: Bool?
        let rank: Int?
    }
}
