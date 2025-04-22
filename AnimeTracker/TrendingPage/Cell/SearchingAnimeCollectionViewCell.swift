//
//  TrendingAnimeCollectionViewCell.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/17.
//

import UIKit

class SearchingAnimeCollectionViewCell: UICollectionViewCell {
    var animeTitle: UILabel!
    var animeCoverImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        animeTitle.numberOfLines = 0
        
    }
    
    func setup(title: String, imageURL: String?) {
        for views in subviews {
            views.removeFromSuperview()
        }
        animeCoverImage = UIImageView()
        animeCoverImage.translatesAutoresizingMaskIntoConstraints = false
        animeCoverImage.contentMode = .scaleAspectFill
        animeCoverImage.clipsToBounds = true
        if let imageURL = imageURL {
            animeCoverImage.loadImage(from: imageURL)
        } else {
            animeCoverImage.image = UIImage(systemName: "photo")
        }
        self.addSubview(animeCoverImage)
        
        
        animeTitle = UILabel()
        animeTitle.sizeToFit()
        animeTitle.font.withSize(25)
        animeTitle?.text = title
        animeTitle.numberOfLines = 0
        animeTitle?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(animeTitle)
        let layoutConstraints: [NSLayoutConstraint] = [
            animeTitle.heightAnchor.constraint(equalToConstant: 80),
            animeTitle.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            animeTitle.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            animeTitle.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            animeCoverImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            animeCoverImage.topAnchor.constraint(equalTo: self.topAnchor),
            animeCoverImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            animeCoverImage.bottomAnchor.constraint(equalTo: animeTitle.topAnchor)
        ]
        self.removeConstraints(layoutConstraints)
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func setCoverImage(image: UIImage) {
        animeCoverImage?.image = image
        print("set image")
    }
}
