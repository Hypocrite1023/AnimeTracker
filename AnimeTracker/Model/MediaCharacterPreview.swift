//
//  MediaCharacterPreview.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/14.
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
            let characterPreview: Response.AnimeDetail.MediaData.Media.CharacterPreview
        }
    }
}
