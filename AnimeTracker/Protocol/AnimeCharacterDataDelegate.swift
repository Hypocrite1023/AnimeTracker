//
//  AnimeCharacterDataDelegate.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/1.
//

import Foundation

protocol AnimeCharacterDataDelegate: AnyObject {
    func animeCharacterDataDelegate(characterData: Response.CharacterDetail)
}

protocol GetAnimeCharacterDataDelegate: AnyObject {
    func getAnimeCharacterData(id: Int, page: Int)
}
