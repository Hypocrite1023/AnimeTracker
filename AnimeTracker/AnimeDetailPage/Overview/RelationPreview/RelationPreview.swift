//
//  RelationPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/24.
//

import UIKit

class RelationPreview: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    let mediaID: Int?
    
    init(frame: CGRect, mediaID: Int) {
        self.mediaID = mediaID
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.mediaID = nil
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("RelationPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        if let mediaID = mediaID {
            let relationPreviewGestureRecognizer = RelationPreviewGestureRecognizer(mediaID: mediaID, target: self, action: #selector(relationPreviewTapped))
            self.addGestureRecognizer(relationPreviewGestureRecognizer)
        }
        
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    func bind(_ model: Model) {
        previewImage.kf.setImage(with: model.animeThumbnailURL)
        if let source = model.source {
            sourceLabel.text = source
        }
        if let title = model.animeTitle {
            titleLabel.text = title
        }
        if let type = model.animeType {
            typeLabel.text = type
        }
        if let status = model.animeStatus {
            statusLabel.text = status
        }
    }
    
    @objc func relationPreviewTapped(sender: RelationPreviewGestureRecognizer) {
        print(sender.mediaID)
    }
}

extension RelationPreview {
    struct Model {
        let animeID: Int
        let animeThumbnailURL: URL?
        let source: String?
        let animeTitle: String?
        let animeType: String?
        let animeStatus: String?
    }
}

class RelationPreviewGestureRecognizer: UITapGestureRecognizer {
    let mediaID: Int
    init(mediaID: Int, target: Any?, action: Selector) {
        self.mediaID = mediaID
        super.init(target: target, action: action)
    }
}
