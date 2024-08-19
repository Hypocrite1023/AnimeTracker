//
//  StaffCollectionViewCell.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/16.
//

import UIKit

enum WorkType {
    case anime, manga
}

class StaffCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var animeCoverImage: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var staffTypeInAnime: UILabel!
    var workType: WorkType!
//    var id: Int!
}
