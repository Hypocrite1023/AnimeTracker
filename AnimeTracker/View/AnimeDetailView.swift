//
//  AnimeDetailView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/19.
//

import UIKit

class AnimeDetailView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var animeTitleLabel: UILabel!
    var animeCoverImageView: UIImageView!// 460 * 650
    var essentialInfoLabelStackView: UIStackView!
    var animeAverageScore: UILabel!
    var animeInfoYearLabel: UILabel!
    var animeInfoSeasonLabel: UILabel!
        
    var buttonsScrollView: UIScrollView!
    var overviewButton: UIButton!
    var watchButton: UIButton!
    var charactersButton: UIButton!
    var staffButton: UIButton!
    var statsButton: UIButton!
    var socialButton: UIButton!
    
    
    var differentViewContainer: UIView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupAnimeInfoPage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAnimeInfoPage() {
        
        animeTitleLabel = UILabel()
        animeTitleLabel.numberOfLines = 0
        animeTitleLabel.adjustsFontSizeToFitWidth = true
        animeTitleLabel.textAlignment = .center
        animeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(animeTitleLabel)
        
        animeAverageScore = UILabelWithPadding(textInsets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        animeAverageScore.text = ""
        animeAverageScore.backgroundColor = #colorLiteral(red: 0, green: 0.8765875101, blue: 0, alpha: 1)
        animeAverageScore.adjustsFontSizeToFitWidth = true
        animeAverageScore.layer.cornerRadius = 15
        animeAverageScore.clipsToBounds = true
        animeAverageScore.translatesAutoresizingMaskIntoConstraints = false
        
        animeInfoYearLabel = UILabelWithPadding(textInsets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        animeInfoYearLabel.text = ""
        animeInfoYearLabel.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        animeInfoYearLabel.adjustsFontSizeToFitWidth = true
        animeInfoYearLabel.layer.cornerRadius = 15
        animeInfoYearLabel.clipsToBounds = true
        animeInfoYearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        animeInfoSeasonLabel = UILabelWithPadding(textInsets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        animeInfoSeasonLabel.text = ""
        animeInfoSeasonLabel.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        animeInfoSeasonLabel.adjustsFontSizeToFitWidth = true
        animeInfoSeasonLabel.layer.cornerRadius = 15
        animeInfoSeasonLabel.clipsToBounds = true
        animeInfoSeasonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        essentialInfoLabelStackView = UIStackView(arrangedSubviews: [animeAverageScore, animeInfoYearLabel, animeInfoSeasonLabel])
        essentialInfoLabelStackView.axis = .horizontal
        essentialInfoLabelStackView.distribution = .fillEqually
        essentialInfoLabelStackView.spacing = 3
        essentialInfoLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(essentialInfoLabelStackView)
        
        animeCoverImageView = UIImageView()
        animeCoverImageView.image = UIImage(systemName: "photo")
        animeCoverImageView.contentMode = .scaleAspectFit
        animeCoverImageView.clipsToBounds = true
        animeCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(animeCoverImageView)
        
        overviewButton = UIButton()
        overviewButton.setTitle("overview".uppercased(), for: .normal)
        overviewButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        overviewButton.translatesAutoresizingMaskIntoConstraints = false
        
        watchButton = UIButton()
        watchButton.setTitle("watch".uppercased(), for: .normal)
        watchButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        watchButton.translatesAutoresizingMaskIntoConstraints = false
        
        charactersButton = UIButton()
        charactersButton.setTitle("characters".uppercased(), for: .normal)
        charactersButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        charactersButton.translatesAutoresizingMaskIntoConstraints = false
        
        staffButton = UIButton()
        staffButton.setTitle("staff".uppercased(), for: .normal)
        staffButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        staffButton.translatesAutoresizingMaskIntoConstraints = false
        
        statsButton = UIButton()
        statsButton.setTitle("stats".uppercased(), for: .normal)
        statsButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        statsButton.translatesAutoresizingMaskIntoConstraints = false
        
        socialButton = UIButton()
        socialButton.setTitle("social".uppercased(), for: .normal)
        socialButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        socialButton.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsScrollView = UIScrollView()
        buttonsScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(buttonsScrollView)

        buttonsScrollView.addSubview(overviewButton)
        buttonsScrollView.addSubview(watchButton)
        buttonsScrollView.addSubview(charactersButton)
        buttonsScrollView.addSubview(staffButton)
        buttonsScrollView.addSubview(statsButton)
        buttonsScrollView.addSubview(socialButton)

        
        differentViewContainer = UIView()
        differentViewContainer.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(differentViewContainer)

    }
    
    func setupAnimeInfoPage(animeDetailData: MediaResponse.MediaData.Media) {
        animeTitleLabel.text = animeDetailData.title.native
        animeAverageScore.text = "SCORE: \(animeDetailData.averageScore)"
        animeInfoYearLabel.text = "YEAR: \(animeDetailData.seasonYear)"
        animeInfoSeasonLabel.text = "SZN: \(animeDetailData.season)"
        animeCoverImageView.loadImage(from: animeDetailData.coverImage.extraLarge!)
    }
    
    

}
