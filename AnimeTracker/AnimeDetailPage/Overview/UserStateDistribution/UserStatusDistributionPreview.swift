//
//  UserStatusDistributionPreview.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/2/21.
//

import UIKit

class UserStatusDistributionPreview: UIView {
    lazy var statusStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    lazy var emptyStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "No status data yet"
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
        if !model.statusAmoutDict.isEmpty {
            let status = model.statusAmoutDict.sorted(by: { $0.value < $1.value }).map(\.key)
            guard let longestStatusValue = model.statusAmoutDict.sorted(by: { $0.value > $1.value }).first?.value else { return }
            let longestStatusWidth = UIScreen.main.bounds.width * 0.6
            for (_, userStatus) in status.enumerated() {
                guard let statusAmount = model.statusAmoutDict[userStatus] else { continue }
                
                let containerHStack = UIStackView()
                containerHStack.axis = .horizontal
                containerHStack.spacing = 5
                
                let statusAmountView = UIView()
                statusAmountView.backgroundColor = StatusColor(rawValue: userStatus)?.value
                statusAmountView.roundCorners(corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 10)
                statusAmountView.snp.makeConstraints { make in
                    make.width.equalTo(longestStatusWidth * CGFloat(statusAmount) / CGFloat(longestStatusValue) + 70)
                    make.height.equalTo(20)
                }
                
                let statusAmountLabel = UILabel()
                statusAmountLabel.text = "\(statusAmount) Users"
                statusAmountLabel.font = .atMicro
                statusAmountLabel.textColor = .atTextPrimary
                statusAmountLabel.adjustsFontSizeToFitWidth = true
                containerHStack.addArrangedSubview(statusAmountView)
                containerHStack.addArrangedSubview(statusAmountLabel)
                
                let statusAmountDescriptionLabel = UILabel()
                statusAmountDescriptionLabel.text = "\(userStatus.capitalized)"
                statusAmountDescriptionLabel.textAlignment = .center
                statusAmountDescriptionLabel.font = .atCaption
                statusAmountDescriptionLabel.textColor = .white
                statusAmountDescriptionLabel.adjustsFontSizeToFitWidth = true
                statusAmountView.addSubview(statusAmountDescriptionLabel)
                statusAmountDescriptionLabel.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                
                statusStackView.addArrangedSubview(containerHStack)
            }
            addSubview(statusStackView)
            statusStackView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(20)
                make.trailing.equalToSuperview().inset(10)
                make.leading.equalToSuperview()
            }
        } else {
            addSubview(emptyStatusLabel)
            emptyStatusLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(20)
                make.top.bottom.equalToSuperview().inset(10)
            }
        }
    }
}

extension UserStatusDistributionPreview {
    struct Model {
        let statusAmoutDict: [String: Int]
    }
    
    enum StatusColor: String {
        case completed = "COMPLETED"
        case current = "CURRENT"
        case planning = "PLANNING"
        case dropped = "DROPPED"
        case pause = "PAUSED"
        
        var value: UIColor {
            switch self {
            case .completed:
                return #colorLiteral(red: 0.4110881686, green: 0.8372716904, blue: 0.2253350019, alpha: 1)
            case .current:
                return #colorLiteral(red: 0.5738196373, green: 0.3378910422, blue: 0.9544720054, alpha: 1)
            case .planning:
                return #colorLiteral(red: 0.00486722542, green: 0.6609873176, blue: 0.9997979999, alpha: 1)
            case .dropped:
                return #colorLiteral(red: 0.9687278867, green: 0.4746391773, blue: 0.6418368816, alpha: 1)
            case .pause:
                return #colorLiteral(red: 0.9119635224, green: 0.3648597598, blue: 0.4597702026, alpha: 1)
            }
        }
    }
}
