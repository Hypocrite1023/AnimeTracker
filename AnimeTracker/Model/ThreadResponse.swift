//
//  ThreadResponse.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

struct ThreadResponse: Decodable {
    let data: PageData
    
    struct PageData: Decodable {
        let Page: Page
        
        struct Page: Decodable {
            let pageInfo: PageInfo
            let threads: [Thread]
            
            struct PageInfo: Decodable {
                let total: Int
                let perPage: Int
                let currentPage: Int
                let lastPage: Int
                let hasNextPage: Bool
            }
            
            struct Thread: Decodable {
                let id: Int
                let title: String
                let replyCount: Int
                let viewCount: Int
                let replyCommentId: Int?
                let repliedAt: Int64
                let createdAt: Int64
                let categories: [Category]
                let user: User
                let replyUser: User?
                
                struct Category: Decodable {
                    let id: Int
                    let name: String
                }
                
                struct User: Decodable {
                    let id: Int
                    let name: String
                    let avatar: Avatar
                    
                    struct Avatar: Decodable {
                        let large: String
                    }
                }
            }
        }
    }
    
    
}
