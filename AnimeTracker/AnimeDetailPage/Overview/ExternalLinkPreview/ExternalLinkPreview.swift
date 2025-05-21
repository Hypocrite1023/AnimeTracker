//
//  ExternalLinkPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit

class ExternalLinkPreview: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var externalLinkIcon: UIImageView!
    @IBOutlet weak var externalLinkTitle: UILabel!
    @IBOutlet weak var externalLinkIconColor: UIView!
    @IBOutlet weak var externalLinkTitleNote: UILabel!
    
    weak var openURLDelegate: OpenUrlDelegate?
    
    var url: String?
    var siteName: String?

    
    init(frame: CGRect, url: String?, siteName: String?) {
        self.url = url
        self.siteName = siteName
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.url = nil
        self.siteName = nil
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("ExternalLinkPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let externalLinkPreviewTapGesture = ExternalLinkPreviewTapGesture(target: self, action: #selector(openURL), url: url, siteName: siteName)
        self.contentView.addGestureRecognizer(externalLinkPreviewTapGesture)
    }
    
    @objc func openURL(sender: ExternalLinkPreviewTapGesture) {
        openURLDelegate?.openURL(siteName: sender.siteName, siteURL: sender.url)
    }
}

class ExternalLinkPreviewTapGesture: UITapGestureRecognizer {
    let url: String?
    let siteName: String?
    init(target: Any?, action: Selector?, url: String?, siteName: String?) {
        self.url = url
        self.siteName = siteName
        super.init(target: target, action: action)
    }
}
