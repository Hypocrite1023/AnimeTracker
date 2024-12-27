//
//  VoiceActorDataResponse.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

struct VoiceActorDataResponse: Codable {
    var data: DataClass
    
    struct DataClass: Codable {
        var Staff: StaffData
        
        struct StaffData: Codable {
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
            
            struct Name: Codable {
                let first: String?
                let middle: String?
                let last: String?
                let full: String?
                let native: String
                let userPreferred: String
                let alternative: [String]?
            }
            
            struct Image: Codable {
                let large: String
            }
            
            struct DateOfBirth: Codable {
                let year: Int?
                let month: Int?
                let day: Int?
            }
            
            struct DateOfDeath: Codable {
                let year: Int?
                let month: Int?
                let day: Int?
            }
            
            struct CharacterMedia: Codable {
                var pageInfo: PageInfo
                let edges: [Edge]?
                
                struct PageInfo: Codable {
                    let total: Int
                    let perPage: Int
                    var currentPage: Int
                    let lastPage: Int
                    var hasNextPage: Bool
                }
                
                struct Edge: Codable {
                    let characterRole: String
                    let characterName: String?
                    let node: Node
                    let characters: [Character]
                    
                    struct Node: Codable {
                        let id: Int
                        let type: String
                        let bannerImage: String?
                        let isAdult: Bool
                        let title: Title
                        let coverImage: CoverImage
                        let startDate: StartDate
                        let mediaListEntry: String?
                        
                        struct Title: Codable {
                            let userPreferred: String
                        }
                        
                        struct CoverImage: Codable {
                            let large: String
                        }
                        
                        struct StartDate: Codable {
                            let year: Int?
                        }
                    }
                    
                    struct Character: Codable {
                        let id: Int
                        let name: Name
                        let image: Image
                        
                        struct Name: Codable {
                            let userPreferred: String
                        }
                        
                        struct Image: Codable {
                            let large: String
                        }
                    }
                }
            }
            
            struct StaffMedia: Codable {
                let pageInfo: PageInfo
                let edges: [Edge]
                
                struct PageInfo: Codable {
                    let total: Int
                    let perPage: Int
                    let currentPage: Int
                    let lastPage: Int
                    let hasNextPage: Bool
                }
                
                struct Edge: Codable {
                    let staffRole: String
                    let node: Node
                    
                    struct Node: Codable {
                        let id: Int
                        let type: String
                        let isAdult: Bool
                        let title: Title
                        let coverImage: CoverImage
                        let mediaListEntry: String?
                        
                        struct Title: Codable {
                            let userPreferred: String
                        }
                        
                        struct CoverImage: Codable {
                            let large: String
                        }
                    }
                }
            }
        }
    }
}

struct VoiceActorData: Codable { // fetch more data
    let data: DataClass
    
    struct DataClass: Codable {
        let Staff: StaffData
        
        struct StaffData: Codable {
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
