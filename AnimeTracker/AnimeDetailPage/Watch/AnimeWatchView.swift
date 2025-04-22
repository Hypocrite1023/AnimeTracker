//
//  AnimeWatchView.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/20.
//

import UIKit

class AnimeWatchView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var watchVStack: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AnimeWatchView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
