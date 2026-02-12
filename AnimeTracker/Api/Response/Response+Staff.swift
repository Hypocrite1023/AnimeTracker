//
//  Response+Staff.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation

extension Response {
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
    
    struct StaffDetailData: Decodable {
        let data: StaffData
        
        struct StaffData: Decodable {
            let staff: Staff
            
            struct Staff: Decodable {
                let id: Int
                let name: Name
                let primaryOccupations: [String]
                let image: StaffImage
                let description: String
                let staffMedia: StaffMedia
                
                struct StaffImage: Decodable {
                    let large: String
                }
                struct StaffMedia: Decodable {
                    let edges: [Edge]
                    struct Edge: Decodable {
                        let staffRole: String
                        let node: Node
                        struct Node: Decodable {
                            let id: Int
                            let coverImage: CoverImage
                            let title: Title
                            let type: String
                            
                            struct Title: Decodable {
                                let native: String
                            }
                            struct CoverImage: Decodable {
                                let large: String
                            }
                        }
                    }
                }
                struct Name: Decodable {
                    let native: String?
                    let userPreferred: String
                }
            }
        }
    }
}
