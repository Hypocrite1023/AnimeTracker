//
//  AnimeWatchPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit

class AnimeWatchPreview: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var animeWatchPreviewImageView: UIImageView!
    @IBOutlet weak var animeWatchPreviewLabel: UILabel!
    
    let streamingSite: String?
    let animeStreamingURL: String?
    weak var openUrlDelegate: OpenUrlDelegate?
    
    init(frame: CGRect, site: String, url: String) {
        self.streamingSite = site
        self.animeStreamingURL = url
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.streamingSite = nil
        self.animeStreamingURL = nil
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AnimeWatchPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        if let url = animeStreamingURL, let site = streamingSite {
            let animeWatchPreviewTapGestureRecognizer = AnimeWatchPreviewTapGestureRecognizer(target: self, action: #selector(watchAnimeStreaming), site: site, url: url)
            self.addGestureRecognizer(animeWatchPreviewTapGestureRecognizer)
        }
        
    }
    
    @objc func watchAnimeStreaming(sender: AnimeWatchPreviewTapGestureRecognizer) {
        print(sender.url)
        openUrlDelegate?.openURL(siteName: sender.site, siteURL: sender.url)
    }

}

class AnimeWatchPreviewTapGestureRecognizer: UITapGestureRecognizer {
    
    let (site, url): (String, String)
    
    init(target: Any?, action: Selector?, site: String, url: String) {
        self.site = site
        self.url = url
        super.init(target: target, action: action)
    }
}
