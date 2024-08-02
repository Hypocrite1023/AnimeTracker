//
//  MediaRanking.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

struct MediaRanking: Decodable {
    let data: MediaData

    struct MediaData: Decodable {
        let media: Media
        
        enum CodingKeys: String, CodingKey {
            case media = "Media"
        }
        struct Media: Decodable {
            let rankings: [Ranking]
            
            struct Ranking: Decodable {
                let rank: Int
                let type: String
                let format: String
                let year: Int?
                let season: String?
                let allTime: Bool?
                let context: String
            }
        }
    }
}
