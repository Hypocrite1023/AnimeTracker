//
//  CharacterPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/25.
//

import UIKit
import Combine

class CharacterPreview: UIView {
    
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
    
    private(set) var characterTapSubject: PassthroughSubject<Int?, Never> = .init()
    private(set) var voiceActorTapSubject: PassthroughSubject<Int?, Never> = .init()
    
    init(frame: CGRect, characterID: Int?, voiceActorID: Int?) {
        self.characterID = characterID
        self.voiceActorID = voiceActorID
        super.init(frame: frame)
        commonInit()
    }
    
    init() {
        super.init(frame: .zero)
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
        setStyle()
    }
    
    func bind(_ model: Model) {
        characterImageView.kf.setImage(with: model.characterImageURL)
        characterNameLabel.text = model.characterName
        characterRoleLabel.text = model.characterRole
        characterID = model.characterID
        
        voiceActorImageView.kf.setImage(with: model.voiceActorImageURL)
        voiceActorNameLabel.text = model.voiceActorName
        voiceActorCountryLabel.text = model.voiceActorCountry
        voiceActorID = model.voiceActorID
        
        let characterSideGesture = UITapGestureRecognizer(target: self, action: #selector(passCharacterID))
        characterSideView.addGestureRecognizer(characterSideGesture)
        
        let voiceActorSideGesture = UITapGestureRecognizer(target: self, action: #selector(passVoiceActorID))
        voiceActorSideView.addGestureRecognizer(voiceActorSideGesture)
    }
    
    func setStyle() {
        contentView.backgroundColor = .clear
        characterSideView.backgroundColor = .clear
        voiceActorSideView.backgroundColor = .clear
        backgroundColor = .atSecondaryBackground
        layer.cornerRadius = 8
        clipsToBounds = true
        
        characterNameLabel.font = .atBody
        characterNameLabel.textColor = .atTextPrimary
        characterRoleLabel.font = .atCaption
        characterRoleLabel.textColor = .atTextSecondary
        
        voiceActorNameLabel.font = .atBody
        voiceActorNameLabel.textColor = .atTextPrimary
        voiceActorCountryLabel.font = .atCaption
        voiceActorCountryLabel.textColor = .atTextSecondary
    }
    
    @objc func passCharacterID(sender: UIGestureRecognizer) {
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
        
        characterTapSubject.send(characterID)
    }
    
    @objc func passVoiceActorID(sender: UIGestureRecognizer) {
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
        
        voiceActorTapSubject.send(voiceActorID)
    }
}

extension CharacterPreview {
    struct Model {
        let characterImageURL: URL?
        let characterName: String?
        let characterRole: String?
        let characterID: Int?
        
        let voiceActorImageURL: URL?
        let voiceActorName: String?
        let voiceActorCountry: String?
        let voiceActorID: Int?
    }
}
