//
//  MediaStaffPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

struct MediaStaffPreview: Decodable {
    let data: MediaData

    struct MediaData: Decodable {
        let media: Media
        
        enum CodingKeys: String, CodingKey {
            case media = "Media"
        }
        struct Media: Decodable {
            let staffPreview: Response.AnimeDetail.MediaData.Media.StaffPreview
        }
    }
}
