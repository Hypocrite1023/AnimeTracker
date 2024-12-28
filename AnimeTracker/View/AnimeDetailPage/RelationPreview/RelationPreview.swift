//
//  RelationPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/24.
//

import UIKit

class RelationPreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
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
        
    }
    
    @objc func relationPreviewTapped(sender: RelationPreviewGestureRecognizer) {
        print(sender.mediaID)
        AnimeDataFetcher.shared.passAnimeID(animeID: sender.mediaID)
    }

}

class RelationPreviewGestureRecognizer: UITapGestureRecognizer {
    
    let mediaID: Int
    init(mediaID: Int, target: Any?, action: Selector) {
        self.mediaID = mediaID
        super.init(target: target, action: action)
    }
}
