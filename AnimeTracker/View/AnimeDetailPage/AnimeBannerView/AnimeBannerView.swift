//
//  AnimeBannerView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/24.
//

import UIKit

class AnimeBannerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var animeBanner: UIImageView!
    @IBOutlet weak var animeThumbnail: UIImageView!
    @IBOutlet weak var animeTitleLabel: UILabel!
    @IBOutlet weak var buttonScrollView: UIScrollView!
    @IBOutlet weak var overviewButton: UIButton!
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var charactersButton: UIButton!
    @IBOutlet weak var staffButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var socialButton: UIButton!

    @IBAction func overviewButtonTap(_ sender: UIButton) {
        sender.setTitleColor(.blue.withAlphaComponent(0.9), for: .normal)
        sender.layer.shadowColor = UIColor.blue.cgColor
        sender.layer.shadowOpacity = 0.7
        sender.layer.shadowOffset = CGSize(width: 2, height: 5)
        sender.layer.shadowRadius = 4
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AnimeBannerView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
