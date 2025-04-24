//
//  AnimeStatsView.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/23.
//

import UIKit

class AnimeStatsView: UIView {
    @IBOutlet var contentView: UIView!
    // rankings
    @IBOutlet weak var rankingsVStack: UIStackView!
    // status distribution
    @IBOutlet weak var statusDistributionFirst: UIButton!
    @IBOutlet weak var statusDistributionFirstLabel: UILabel!
    @IBOutlet weak var statusDistributionSecond: UIButton!
    @IBOutlet weak var statusDistributionSecondLabel: UILabel!
    @IBOutlet weak var statusDistributionThird: UIButton!
    @IBOutlet weak var statusDistributionThirdLabel: UILabel!
    @IBOutlet weak var statusDistributionFourth: UIButton!
    @IBOutlet weak var statusDistributionFourthLabel: UILabel!
    @IBOutlet weak var statusDistributionFifth: UIButton!
    @IBOutlet weak var statusDistributionFifthLabel: UILabel!
    @IBOutlet weak var statusDistributionPercentView: UIView!
    // score distribution
    @IBOutlet weak var scoreDistributionHStack: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AnimeStatsView", owner: self)
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
