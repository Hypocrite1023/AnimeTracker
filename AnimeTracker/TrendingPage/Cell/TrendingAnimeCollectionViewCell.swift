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
    }
    
    func setCell(title: String, imageURL: String?) {
        animeNameLabel.text = title
        animeThumbnail.kf.setImage(with: URL(string: imageURL ?? ""))
    }

}
