//
//  Response+Character.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation

extension Response {
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
    
    struct CharacterDetail: Decodable {
        var data: CharacterData
        
        struct CharacterData: Decodable {
            var Character: CharacterDataInData
            
            struct CharacterDataInData: Decodable {
                let id: Int
                let name: CharacterName
                let image: CharacterImage
                let favourites: Int
                let isFavourite: Bool
                let isFavouriteBlocked: Bool
                let description: String?
                let age: String?
                let gender: String?
                let bloodType: String?
                let dateOfBirth: DateOfBirth
                var media: Media?
                
                struct Media: Decodable {
                    let pageInfo: PageInfo
                    var edges: [Edge]
                    
                    
                    struct Edge: Decodable {
                        let id: Int
                        let characterRole: String
                        var voiceActorRoles: [VoiceActorRoles]?
                        let node: Node
                        
                        struct Node: Decodable {
                            let id: Int
                            let type: String?
                            let isAdult: Bool
                            let bannerImage: String?
                            let title: Title
                            let coverImage: Response.AnimeDetail.MediaData.Media.MediaCoverImage
                            let startDate: StartDate
                            let mediaListEntry: MediaListEntry?
                            
                            struct MediaListEntry: Decodable {
                                let id: Int
                                let status: String?
                            }
                            
                            struct StartDate: Decodable {
                                let year: Int?
                            }
                            
                            struct Title: Decodable {
                                let userPreferred: String
                            }
                        }
                        
                        struct VoiceActorRoles: Decodable {
                            let roleNotes: String?
                            let voiceActor: Response.AnimeDetail.MediaData.Media.CharacterPreview.Edges.VoiceActors
                            
                        }
                    }
                    
                    struct PageInfo: Decodable {
                        let total: Int
                        let perPage: Int
                        let currentPage: Int
                        let lastPage: Int
                        let hasNextPage: Bool
                    }
                }
                
                struct DateOfBirth: Decodable {
                    let year: Int?
                    let month: Int?
                    let day: Int?
                }
                
                struct CharacterName: Decodable {
                    let first: String?
                    let middle: String?
                    let last: String?
                    let full: String?
                    let native: String?
                    let userPreferred: String
                    let alternative: [String]?
                    let alternativeSpoiler: [String]?
                }
                
                struct CharacterImage: Decodable {
                    let large: String
                }
            }
        }
    }
}
