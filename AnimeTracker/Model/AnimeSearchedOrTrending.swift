//
//  AnimeSearchedOrTrending.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

struct AnimeSearchedOrTrending: Codable {
    var data: Page
    
    struct Page: Codable {
        var Page: PageInfoAndMedia
        
        struct PageInfoAndMedia: Codable {
            var media: [Anime]
            var pageInfo: PageInfo
            
            struct Anime: Codable {
                let id: Int
                let title: Title
                let coverImage: CoverImage
                
                struct Title: Codable {
                    let native: String
                }
                struct CoverImage: Codable {
                    let extraLarge: String
                }
            }
            struct PageInfo: Codable {
                var currentPage: Int
                let hasNextPage: Bool
            }
        }
    }
    
    
    
}
