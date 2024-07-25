//
//  StatusDistributionView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/25.
//

import UIKit

class StatusDistributionView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var firstTextLabel: UIButton!
    @IBOutlet weak var secondTextLabel: UIButton!
    @IBOutlet weak var thirdTextLabel: UIButton!
    @IBOutlet weak var fourthTextLabel: UIButton!
    @IBOutlet weak var fifthTextLabel: UIButton!
    
    @IBOutlet weak var firstUsersLabel: UILabel!
    @IBOutlet weak var secondUsersLabel: UILabel!
    @IBOutlet weak var thirdUsersLabel: UILabel!
    @IBOutlet weak var fourthUsersLabel: UILabel!
    @IBOutlet weak var fifthUsersLabel: UILabel!
    
    @IBOutlet weak var persentView: UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("StatusDistributionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}
