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
    
    var animeDescriptionText: UITextView!
    
    var buttonsScrollView: UIScrollView!
    var detailViewButtonsView: UIView!
    var overviewButton: UIButton!
    var watchButton: UIButton!
    var charactersButton: UIButton!
    var staffButton: UIButton!
    var statsButton: UIButton!
    var socialButton: UIButton!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupAnimeInfoPage(animeDetailData: MediaResponse.MediaData.Media) {
        
        animeTitleLabel = UILabel()
        animeTitleLabel.text = animeDetailData.title.native
        animeTitleLabel.numberOfLines = 0
        animeTitleLabel.adjustsFontSizeToFitWidth = true
        animeTitleLabel.textAlignment = .center
        animeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(animeTitleLabel)
        
        animeAverageScore = UILabelWithPadding(textInsets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        animeAverageScore.text = "SCORE: \(animeDetailData.averageScore)"
        animeAverageScore.backgroundColor = #colorLiteral(red: 0, green: 0.8765875101, blue: 0, alpha: 1)
        animeAverageScore.adjustsFontSizeToFitWidth = true
        animeAverageScore.layer.cornerRadius = 15
        animeAverageScore.clipsToBounds = true
        animeAverageScore.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(animeAverageScore)
        
        animeInfoYearLabel = UILabelWithPadding(textInsets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        animeInfoYearLabel.text = "YEAR: \(animeDetailData.seasonYear)"
        animeInfoYearLabel.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        animeInfoYearLabel.adjustsFontSizeToFitWidth = true
        animeInfoYearLabel.layer.cornerRadius = 15
        animeInfoYearLabel.clipsToBounds = true
        animeInfoYearLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(animeInfoYearLabel)
        
        animeInfoSeasonLabel = UILabelWithPadding(textInsets: UIEdgeInsets(top: 3, left: 5, bottom: 3, right: 5))
        animeInfoSeasonLabel.text = "SZN: \(animeDetailData.season)"
        animeInfoSeasonLabel.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        animeInfoSeasonLabel.adjustsFontSizeToFitWidth = true
        animeInfoSeasonLabel.layer.cornerRadius = 15
        animeInfoSeasonLabel.clipsToBounds = true
        animeInfoSeasonLabel.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(animeInfoSeasonLabel)
        
        essentialInfoLabelStackView = UIStackView(arrangedSubviews: [animeAverageScore, animeInfoYearLabel, animeInfoSeasonLabel])
        essentialInfoLabelStackView.axis = .horizontal
        essentialInfoLabelStackView.distribution = .fillEqually
        essentialInfoLabelStackView.spacing = 3
        essentialInfoLabelStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(essentialInfoLabelStackView)
        
        animeCoverImageView = UIImageView()
        animeCoverImageView.loadImage(from: animeDetailData.coverImage.extraLarge!)
//        print(animeCoverImageView.image?.size)
        animeCoverImageView.contentMode = .scaleAspectFit
        animeCoverImageView.clipsToBounds = true
        animeCoverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(animeCoverImageView)
        
        animeDescriptionText = UITextView()
        animeDescriptionText.font = UIFont.systemFont(ofSize: 20)
        animeDescriptionText.text = animeDetailData.description.replacingOccurrences(of: "<br>", with: "\n").replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "<i>", with: "").replacingOccurrences(of: "</i>", with: "")
        animeDescriptionText.textAlignment = .left
        animeDescriptionText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(animeDescriptionText)
        
//        detailViewButtonsView = UIView()
//        detailViewButtonsView.bounds.size = CGSize(width: 600, height: 100)
//        detailViewButtonsView.translatesAutoresizingMaskIntoConstraints = false
        
        overviewButton = UIButton()
        overviewButton.setTitle("overview".uppercased(), for: .normal)
        overviewButton.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
//        overviewButton.layer.cornerRadius = 10
        overviewButton.layer.borderColor = UIColor.red.cgColor
        overviewButton.layer.borderWidth = 3
//        overviewButton.clipsToBounds = true
        overviewButton.translatesAutoresizingMaskIntoConstraints = false
//        detailViewButtonsView.addSubview(overviewButton)
        watchButton = UIButton()
        watchButton.setTitle("watch".uppercased(), for: .normal)
        watchButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        watchButton.translatesAutoresizingMaskIntoConstraints = false
//        detailViewButtonsView.addSubview(watchButton)
        charactersButton = UIButton()
        charactersButton.setTitle("characters".uppercased(), for: .normal)
        charactersButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        charactersButton.translatesAutoresizingMaskIntoConstraints = false
//        detailViewButtonsView.addSubview(charactersButton)
        staffButton = UIButton()
        staffButton.setTitle("staff".uppercased(), for: .normal)
        staffButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        staffButton.translatesAutoresizingMaskIntoConstraints = false
//        detailViewButtonsView.addSubview(staffButton)
        statsButton = UIButton()
        statsButton.setTitle("stats".uppercased(), for: .normal)
        statsButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        statsButton.translatesAutoresizingMaskIntoConstraints = false
//        detailViewButtonsView.addSubview(statsButton)
        socialButton = UIButton()
        socialButton.setTitle("social".uppercased(), for: .normal)
        socialButton.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        socialButton.translatesAutoresizingMaskIntoConstraints = false
//        detailViewButtonsView.addSubview(socialButton)
        
        buttonsScrollView = UIScrollView()
        buttonsScrollView.translatesAutoresizingMaskIntoConstraints = false
        buttonsScrollView.addSubview(overviewButton)
        buttonsScrollView.addSubview(watchButton)
        buttonsScrollView.addSubview(charactersButton)
        buttonsScrollView.addSubview(staffButton)
        buttonsScrollView.addSubview(statsButton)
        buttonsScrollView.addSubview(socialButton)

        self.addSubview(buttonsScrollView)

    }

}
