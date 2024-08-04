//
//  CharacterPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/25.
//

import UIKit

class CharacterPreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var voiceActorImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var voiceActorNameLabel: UILabel!
    @IBOutlet weak var characterRoleLabel: UILabel!
    @IBOutlet weak var voiceActorCountryLabel: UILabel!
    @IBOutlet weak var characterSideView: UIView!
    @IBOutlet weak var voiceActorSideView: UIView!
    
    var characterID: Int?
    var voiceActorID: Int?
    weak var animeCharacterDataManager: GetAnimeCharacterDataDelegate?
    weak var voiceActorDataManager: FetchAnimeVoiceActorData?

    
    init(frame: CGRect, characterID: Int?, voiceActorID: Int?) {
        self.characterID = characterID
        self.voiceActorID = voiceActorID
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("CharacterPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let characterID = characterID {
            let characterSideGesture = CharacterTapGesture(target: self, action: #selector(loadCharacterData), characterID: characterID)
            characterSideView.addGestureRecognizer(characterSideGesture)
        }
        if let voiceActorID = voiceActorID {
            let voiceActorSideGesture = VoiceActorTapGesture(target: self, action: #selector(loadVoiceActorData), voiceActorID: voiceActorID)
            voiceActorSideView.addGestureRecognizer(voiceActorSideGesture)
        }
        
        
    }
    
    @objc func loadCharacterData(sender: CharacterTapGesture) {
        print(sender.characterID)
        
        guard let view = sender.view?.superview else { return }
                
        // Animate scaling effect
        UIView.animate(withDuration: 0.1,
                       animations: {
                           view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               view.transform = CGAffineTransform.identity
                           }
                       })
        
        animeCharacterDataManager?.getAnimeCharacterData(id: sender.characterID, page: 1)
    }
    @objc func loadVoiceActorData(sender: VoiceActorTapGesture) {
        print(sender.voiceActorID)
        guard let view = sender.view?.superview else { return }
                
        // Animate scaling effect
        UIView.animate(withDuration: 0.1,
                       animations: {
                           view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.1) {
                               view.transform = CGAffineTransform.identity
                           }
                       })
        voiceActorDataManager?.fetchAnimeVoiceActorData(id: sender.voiceActorID, page: 1)
    }
}

class CharacterTapGesture: UITapGestureRecognizer {
    let characterID: Int
    
    init(target: Any?, action: Selector?, characterID: Int) {
        self.characterID = characterID
        super.init(target: target, action: action)
    }
    
}

class VoiceActorTapGesture: UITapGestureRecognizer {
    let voiceActorID: Int
    
    init(target: Any?, action: Selector?, voiceActorID: Int) {
        self.voiceActorID = voiceActorID
        super.init(target: target, action: action)
    }
    
}
