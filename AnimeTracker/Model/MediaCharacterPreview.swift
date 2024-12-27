//
//  MediaCharacterPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

struct MediaCharacterPreview: Decodable {
    let data: MediaData

    struct MediaData: Decodable {
        let media: Media
        
        enum CodingKeys: String, CodingKey {
            case media = "Media"
        }
        struct Media: Decodable {
            let characterPreview: MediaResponse.MediaData.Media.CharacterPreview
        }
    }
}
