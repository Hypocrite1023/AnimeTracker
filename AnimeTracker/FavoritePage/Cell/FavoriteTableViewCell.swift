//
//  FavoriteTableViewCell.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    @IBOutlet weak var animeCoverImageView: UIImageView!
    @IBOutlet weak var animeTitleLabel: UILabel!
    @IBOutlet weak var isFavoriteBtn: UIButton! {
        didSet {
            isFavoriteBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small), forImageIn: .normal)
            isFavoriteBtn.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    @IBOutlet weak var isNotifyBtn: UIButton! {
        didSet {
            isNotifyBtn.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(scale: .small), forImageIn: .normal)
            isNotifyBtn.setImage(UIImage(systemName: "bell.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    var animeID: Int!
    var isFavorite: Bool!
    var isNotify: Bool!
    var status: String!
    weak var favoriteAndNotifyConfig: ConfigFavoriteAndNotifyWithAnimeID?
    weak var configNotify: ConfigAnimeNotify?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func isFavoriteBtnClick(_ sender: UIButton) {
        isFavorite.toggle()
        sender.tintColor = isFavorite ? .systemYellow : .lightGray
        favoriteAndNotifyConfig?.configFavoriteAndNotifyWithAnimeID(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
    }
    @IBAction func isNotifyBtnClick(_ sender: UIButton) {
        isNotify.toggle()
        sender.tintColor = isNotify ? .systemBlue : .lightGray
        favoriteAndNotifyConfig?.configFavoriteAndNotifyWithAnimeID(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
        
        configNotify?.configAnimeNotify(animeID: animeID, isNotify: isNotify)
        
    }
    
    func configBtnColor(isFavorite: Bool, isNotify: Bool, status: String) {
        self.isFavorite = isFavorite
        self.isNotify = isNotify
        self.status = status
        
        DispatchQueue.main.async {
            if status == "RELEASING" {
                self.isNotifyBtn.isHidden = false
            } else {
                self.isNotifyBtn.isHidden = true
            }
            self.isFavoriteBtn.tintColor = isFavorite ? .systemYellow : .lightGray
            self.isNotifyBtn.tintColor = isNotify ? .systemBlue : .lightGray
        }
    }

}

protocol ConfigFavoriteAndNotifyWithAnimeID: AnyObject {
    func configFavoriteAndNotifyWithAnimeID(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String)
}

protocol ConfigAnimeNotify: AnyObject {
    func configAnimeNotify(animeID: Int, isNotify: Bool)
}
