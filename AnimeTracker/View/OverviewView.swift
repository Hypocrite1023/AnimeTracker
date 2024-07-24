//
//  OverviewView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/21.
//

import UIKit

class OverviewView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var animeDescriptionDelegate: AnimeDescriptionDelegate?
//    private var contentScrollView: UIScrollView!
    private var animeDescriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
//        contentScrollView = UIScrollView()
//        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
//        self.addSubview(contentScrollView)
        animeDescriptionLabel = UILabel()
        animeDescriptionLabel.numberOfLines = 0
        animeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
//        contentScrollView.addSubview(animeDescriptionLabel)
        self.addSubview(animeDescriptionLabel)
        
        NSLayoutConstraint.activate([
//            contentScrollView.topAnchor.constraint(equalTo: self.topAnchor),
//            contentScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            contentScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            contentScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            tmpLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            tmpLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            tmpLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            animeDescriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            animeDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            animeDescriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            animeDescriptionLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            animeDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("overviewview deinit")
    }
    
    

}
