//
//  WatchViewCollectionViewCell.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/22.
//

import UIKit

class WatchViewCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "StreamCell"
    
    var episodeTitleLabel: UILabel!
    var episodeThumbnailImageView: UIImageView!
    
    func setupCell(title: String, imageURL: String) {
        episodeTitleLabel = UILabelWithPadding(textInsets: UIEdgeInsets(top: 2, left: 3, bottom: 2, right: 3))
        episodeTitleLabel.text = title
        episodeTitleLabel.textColor = .white
        episodeTitleLabel.backgroundColor = .black.withAlphaComponent(0.5)
        episodeTitleLabel.numberOfLines = 0
        episodeTitleLabel.adjustsFontSizeToFitWidth = true
        episodeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        episodeThumbnailImageView = UIImageView()
        episodeThumbnailImageView.loadImage(from: imageURL)
        episodeThumbnailImageView.contentMode = .scaleAspectFill
        episodeThumbnailImageView.clipsToBounds = true
        episodeThumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(episodeThumbnailImageView)
        self.addSubview(episodeTitleLabel)
    }
    
    func setupConstraints() {
        episodeThumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        episodeThumbnailImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        episodeThumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        episodeThumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        episodeTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        episodeTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        episodeTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        episodeTitleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}
