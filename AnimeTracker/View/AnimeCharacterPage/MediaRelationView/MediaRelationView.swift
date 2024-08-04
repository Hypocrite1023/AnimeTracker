//
//  MediaRelationView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/1.
//

import UIKit

class MediaRelationView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var animeCoverImage: UIImageView!
    @IBOutlet weak var animeTitle: UILabel!
    @IBOutlet weak var relationVoiceActor: UILabel!
    
    let animeID: Int?
    let characterID: Int?
    
    weak var characterIdDelegate: CharacterIdDelegate?
    weak var animeIdDelegate: FetchAnimeDetailDataByID?
    
    init(frame: CGRect, animeID: Int?, characterID: Int?) {
        self.animeID = animeID
        self.characterID = characterID
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.animeID = nil
        self.characterID = nil
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("MediaRelationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let mediaRelationTapGesture = MediaRelationTapGesture(target: self, action: #selector(loadAnimeOrLoadCharacter), animeID: self.animeID, characterID: self.characterID)
        self.addGestureRecognizer(mediaRelationTapGesture)
    }

    @objc func loadAnimeOrLoadCharacter(sender: MediaRelationTapGesture) {
        if let characterID = sender.characterID {
            characterIdDelegate?.passCharacterID(characterID: characterID)
        }
        if let animeID = sender.animeID {
            print("animeID")
            animeIdDelegate?.passAnimeID(animeID: animeID)
        }
    }
}

class MediaRelationTapGesture: UITapGestureRecognizer {
    let animeID: Int?
    let characterID: Int?
    
    init(target: Any?, action: Selector?, animeID: Int?, characterID: Int?) {
        self.animeID = animeID
        self.characterID = characterID
        super.init(target: target, action: action)
    }
    
    
}

protocol CharacterIdDelegate: AnyObject {
    func passCharacterID(characterID: Int)
}
