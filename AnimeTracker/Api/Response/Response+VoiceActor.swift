//
//  Response+VoiceActor.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation

extension Response {
    struct VoiceActorDataResponse: Decodable {
        var data: DataClass
        
        struct DataClass: Decodable {
            var Staff: StaffData
            
            struct StaffData: Decodable {
                let id: Int
                let name: Name
                let image: Image
                let description: String?
                let favourites: Int?
                let isFavourite: Bool?
                let isFavouriteBlocked: Bool?
                let age: Int?
                let gender: String?
                let yearsActive: [Int]?
                let homeTown: String?
                let bloodType: String?
                let primaryOccupations: [String]?
                let dateOfBirth: DateOfBirth?
                let dateOfDeath: DateOfDeath?
                let language: String?
                var characterMedia: CharacterMedia?
                let staffMedia: StaffMedia?
                
                struct Name: Decodable {
                    let first: String?
                    let middle: String?
                    let last: String?
                    let full: String?
                    let native: String
                    let userPreferred: String
                    let alternative: [String]?
                }
                
                struct Image: Decodable {
                    let large: String
                }
                
                struct DateOfBirth: Decodable {
                    let year: Int?
                    let month: Int?
                    let day: Int?
                }
                
                struct DateOfDeath: Decodable {
                    let year: Int?
                    let month: Int?
                    let day: Int?
                }
                
                struct CharacterMedia: Decodable {
                    var pageInfo: PageInfo
                    let edges: [Edge]?
                    
                    struct PageInfo: Decodable {
                        let total: Int
                        let perPage: Int
                        var currentPage: Int
                        let lastPage: Int
                        var hasNextPage: Bool
                    }
                    
                    struct Edge: Decodable {
                        let characterRole: String
                        let characterName: String?
                        let node: Node
                        let characters: [Character]
                        
                        struct Node: Decodable {
                            let id: Int
                            let type: String
                            let bannerImage: String?
                            let isAdult: Bool
                            let title: Title
                            let coverImage: CoverImage
                            let startDate: StartDate
                            let mediaListEntry: String?
                            
                            struct Title: Decodable {
                                let userPreferred: String
                            }
                            
                            struct CoverImage: Decodable {
                                let large: String
                            }
                            
                            struct StartDate: Decodable {
                                let year: Int?
                            }
                        }
                        
                        struct Character: Decodable {
                            let id: Int
                            let name: Name
                            let image: Image
                            
                            struct Name: Decodable {
                                let userPreferred: String
                            }
                            
                            struct Image: Decodable {
                                let large: String
                            }
                        }
                    }
                }
                
                struct StaffMedia: Decodable {
                    let pageInfo: PageInfo
                    let edges: [Edge]
                    
                    struct PageInfo: Decodable {
                        let total: Int
                        let perPage: Int
                        let currentPage: Int
                        let lastPage: Int
                        let hasNextPage: Bool
                    }
                    
                    struct Edge: Decodable {
                        let staffRole: String
                        let node: Node
                        
                        struct Node: Decodable {
                            let id: Int
                            let type: String
                            let isAdult: Bool
                            let title: Title
                            let coverImage: CoverImage
                            let mediaListEntry: String?
                            
                            struct Title: Decodable {
                                let userPreferred: String
                            }
                            
                            struct CoverImage: Decodable {
                                let large: String
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct VoiceActorData: Decodable { // fetch more data
        let data: DataClass
        
        struct DataClass: Decodable {
            let Staff: StaffData
            
            struct StaffData: Decodable {
                let characterMedia: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia?
                
    //            struct CharacterMedia: Codable {
    //                let pageInfo: PageInfo
    //                let edges: [Edge]?
    //
    //                struct PageInfo: Codable {
    //                    let total: Int
    //                    let perPage: Int
    //                    let currentPage: Int
    //                    let lastPage: Int
    //                    let hasNextPage: Bool
    //                }
    //
    //                struct Edge: Codable {
    //                    let characterRole: String
    //                    let characterName: String?
    //                    let node: Node
    //                    let characters: [Character]
    //
    //                    struct Node: Codable {
    //                        let id: Int
    //                        let type: String
    //                        let bannerImage: String?
    //                        let isAdult: Bool
    //                        let title: Title
    //                        let coverImage: CoverImage
    //                        let startDate: StartDate
    //                        let mediaListEntry: String?
    //
    //                        struct Title: Codable {
    //                            let userPreferred: String
    //                        }
    //
    //                        struct CoverImage: Codable {
    //                            let large: String
    //                        }
    //
    //                        struct StartDate: Codable {
    //                            let year: Int?
    //                        }
    //                    }
    //
    //                    struct Character: Codable {
    //                        let id: Int
    //                        let name: Name
    //                        let image: Image
    //
    //                        struct Name: Codable {
    //                            let userPreferred: String
    //                        }
    //
    //                        struct Image: Codable {
    //                            let large: String
    //                        }
    //                    }
    //                }
    //            }
            }
        }
    }
}
