//
//  CharacterRelationCollectionViewCell.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/21.
//

import UIKit

class CharacterRelationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var animeCoverImage: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var voiceActorName: UILabel!
    @IBOutlet weak var voiceActorImage: UIImageView!
    var cellType: String?
    
}
