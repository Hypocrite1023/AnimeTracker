//
//  TrendingAnimeCollectionViewCell.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/16.
//

import UIKit
import Kingfisher

class TrendingAnimeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var animeThumbnail: UIImageView!
    @IBOutlet weak var animeNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
        animeNameLabel.font = .atSubheadline
        animeNameLabel.lineBreakMode = .byTruncatingTail
        animeNameLabel.textAlignment = .center
        
        animeThumbnail.layer.cornerRadius = 5
        animeThumbnail.clipsToBounds = true
    }
    
    func setCell(title: String, imageURL: String?) {
        animeNameLabel.text = title
        
        animeThumbnail.kf.setImage(
            with: URL(string: imageURL ?? ""),
            options: [
                .memoryCacheExpiration(.seconds(30)),
            ]
        )
    }

}
