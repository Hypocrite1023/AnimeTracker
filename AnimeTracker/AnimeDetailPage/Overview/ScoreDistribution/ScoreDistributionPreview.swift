//
//  ScoreDistributionPreview.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/2/21.
//

import UIKit

class ScoreDistributionPreview: UIView {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var scoreHorizonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        stack.distribution = .fillEqually
        stack.alignment = .bottom
        return stack
    }()
    
    lazy var emptyScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "No score data yet"
        label.font = .atBody
        label.textColor = .atTextPrimary
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .atSecondaryBackground
        layer.cornerRadius = 8
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ model: Model) {
        if !model.scoreAmountDict.isEmpty {
            let scores = model.scoreAmountDict.keys.sorted(by: { lhs, rhs in
                return Int(lhs) ?? .zero < Int(rhs) ?? .zero
            })
            let scoreAmountTotal = model.scoreAmountDict.values.reduce(0, +)
            for (index, score) in scores.enumerated() {
                guard let scoreAmount = model.scoreAmountDict[score] else { continue }
                
                let scoreDistributionContainer = UIStackView()
                scoreDistributionContainer.axis = .vertical
                scoreDistributionContainer.spacing = 10
                scoreDistributionContainer.alignment = .center
                scoreDistributionContainer.snp.makeConstraints { make in
                    make.width.equalTo(30)
                }
                
                let percent = AnimeDetailFunc.partOfAmount(value: scoreAmount, totalValue: scoreAmountTotal)
                let percentLabel = UILabel()
                percentLabel.text = String(format: "%.1f%%", percent * 100)
                percentLabel.font = .atCaption
                percentLabel.textColor = .atTextPrimary
                percentLabel.adjustsFontSizeToFitWidth = true
                scoreDistributionContainer.addArrangedSubview(percentLabel)
                percentLabel.snp.makeConstraints { make in
                    make.width.equalToSuperview()
                    make.centerX.equalToSuperview()
                }
                
                let scoreView = UIView()
                scoreView.layer.cornerRadius = 5
                scoreView.clipsToBounds = true
                
                // 0 1 2 3 4(yellow) | 5 6 7 8 9
                if index < 5 {
                    scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemRed, color2: UIColor.systemYellow, fraction: CGFloat(index) / 5)
                } else {
                    scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemYellow, color2: UIColor.systemGreen, fraction: CGFloat(index - 4) / 5)
                }
                scoreDistributionContainer.addArrangedSubview(scoreView)
                scoreView.snp.makeConstraints { make in
                    make.height.equalTo(100 * percent + 10)
                    make.width.equalTo(25)
                }
                
                let scoreLabel = UILabel()
                scoreLabel.textAlignment = .center
                scoreLabel.text = "\(score)"
                scoreLabel.font = .atCaption
                scoreLabel.adjustsFontSizeToFitWidth = true
                scoreLabel.textColor = .atTextSecondary
                scoreDistributionContainer.addArrangedSubview(scoreLabel)
                scoreLabel.snp.makeConstraints { make in
                    make.width.equalToSuperview()
                    make.centerX.equalToSuperview()
                }
                
                scoreHorizonStack.addArrangedSubview(scoreDistributionContainer)
            }
            scrollView.addSubview(scoreHorizonStack)
            scoreHorizonStack.snp.makeConstraints { make in
                make.leading.trailing.equalTo(scrollView.contentLayoutGuide).inset(10)
                make.top.bottom.equalTo(scrollView.frameLayoutGuide).inset(20)
//                make.height.equalTo(scrollView.frameLayoutGuide)
            }
            addSubview(scrollView)
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            addSubview(emptyScoreLabel)
            emptyScoreLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(20)
                make.top.bottom.equalToSuperview().inset(10)
            }
        }
    }
}

extension ScoreDistributionPreview {
    struct Model {
        let scoreAmountDict: [String: Int]
    }
}
