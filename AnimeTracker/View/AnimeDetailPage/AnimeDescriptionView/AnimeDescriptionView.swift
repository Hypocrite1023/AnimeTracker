//
//  AnimeDescriptionView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/24.
//

import Foundation
import UIKit

class AnimeDescriptionView: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var descriptionBody: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("AnimeDescriptionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
