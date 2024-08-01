//
//  CharacterTapGesture.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/31.
//

import UIKit

class CharacterTapGesture: UITapGestureRecognizer {
    let characterID: Int
    
    init(target: Any?, action: Selector?, characterID: Int) {
        self.characterID = characterID
        super.init(target: target, action: action)
    }
    
}
