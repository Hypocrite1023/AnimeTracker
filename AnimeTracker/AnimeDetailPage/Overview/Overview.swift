//
//  Overview.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/18.
//

import UIKit

class Overview: UIView {
    @IBOutlet var contentView: UIView!
    // information
    @IBOutlet weak var airingLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var episodesLabel: UILabel!
    @IBOutlet weak var episodesDurationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var averageScoreLabel: UILabel!
    @IBOutlet weak var meanScoreLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var studiosLabel: UILabel!
    @IBOutlet weak var producersLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var hashTagLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var romajiLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var nativeLabel: UILabel!
    @IBOutlet weak var synonymsLabel: UILabel!
    // description
    @IBOutlet weak var descriptionContextLabel: UILabel!
    // relation
    @IBOutlet weak var relationHStackView: UIStackView!
    // character
    @IBOutlet weak var charactersVStackView: UIStackView!
    // staff
    @IBOutlet weak var staffsVStackView: UIStackView!
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
    // watch
    @IBOutlet weak var watchHStack: UIStackView!
    // recommendations
    @IBOutlet weak var recommendationsHStack: UIStackView!
    // reviews
    @IBOutlet weak var reviewsVStack: UIStackView!
    // external & streaming link
    @IBOutlet weak var linkVStack: UIStackView!
    // tags
    @IBOutlet weak var tagsVStack: UIStackView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("Overview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
