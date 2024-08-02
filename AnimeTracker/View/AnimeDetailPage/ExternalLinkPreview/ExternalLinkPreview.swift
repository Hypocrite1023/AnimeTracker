//
//  ExternalLinkPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit

class ExternalLinkPreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var externalLinkIcon: UIImageView!
    @IBOutlet weak var externalLinkTitle: UILabel!
    @IBOutlet weak var externalLinkIconColor: UIView!
    @IBOutlet weak var externalLinkTitleNote: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("ExternalLinkPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}