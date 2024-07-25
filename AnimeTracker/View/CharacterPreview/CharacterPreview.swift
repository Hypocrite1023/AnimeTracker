//
//  CharacterPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/25.
//

import UIKit

class CharacterPreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var voiceActorImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var voiceActorNameLabel: UILabel!
    @IBOutlet weak var characterRoleLabel: UILabel!
    @IBOutlet weak var voiceActorCountryLabel: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("CharacterPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
