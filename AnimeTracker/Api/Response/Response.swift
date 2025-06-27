//
//  Response.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/14.
//

import Foundation

struct Response {
}

// MARK: - The resposne base on page
extension Response {
    
    typealias AnimeTrending = AnimeSummary
    typealias AnimeCategory = AnimeSummary
    typealias AnimeSearching = AnimeSummary
    
    struct AnimeSummary: Codable {
        var data: Page
        
        struct Page: Codable {
            var page: PageInfoAndMedia
            
            enum CodingKeys: String, CodingKey {
                case page = "Page"
            }
            
            struct PageInfoAndMedia: Codable {
                var media: [AnimeEssentialData]
                var pageInfo: PageInfo
                
                struct PageInfo: Codable {
                    var currentPage: Int
                    var hasNextPage: Bool
                }
            }
        }
    }
    
    struct AnimeEssentialData: Codable {
        let id: Int
        let title: Title
        let coverImage: CoverImage?
        let status: String?
        
        struct Title: Codable {
            let native: String?
            let english: String?
            let romaji: String?
        }
        
        struct CoverImage: Codable {
            let large: String
        }
    }
}

// MARK: - Anime Response
extension Response {
    struct AnimeDetail: Decodable {
        let data: MediaData

        struct MediaData: Decodable {
            let media: Media

            enum CodingKeys: String, CodingKey {
                case media = "Media"
            }

            // airing, format, episodes, episode duration, status, start date, season, average score, mean score, popularity, favorites, studios, producers, source, hashtag, genres, romaji, english, native, synonyms
            struct Media: Decodable {
                let id: Int
                let title: MediaTitle
                let coverImage: MediaCoverImage?
                
                let seasonYear: Int?
                let season: String?
                
                let description: String?
                let streamingEpisodes: [StreamingEpisodes]
                let bannerImage: String?
                let nextAiringEpisode: NextAiringEpisode?
                let format: String?
                let episodes: Int?
                let duration: Int? // minute
                let status: String?
                let startDate: StartDate?
                let averageScore: Int?
                let meanScore: Int?
                let popularity: Int?
                let favourites: Int?
                let studios: Studios? // also contain producers
                let source: String?
                let hashtag: String?
                let genres: [String]?
                let synonyms: [String]?
                let relations: Relations?
                var characterPreview: CharacterPreview?
                var staffPreview: StaffPreview?
                let stats: Stats?
                let recommendations: Recommendations?
                let reviewPreview: ReviewPreview?
                let externalLinks: [ExternalLinks]?
                let tags: [Tag]?
                
                struct Tag: Decodable {
                    let id: Int
                    let name: String
                    let description: String?
                    let rank: Int
                    let isMediaSpoiler: Bool
                    let isGeneralSpoiler: Bool
                    let userId: Int?
                }
                
                struct ExternalLinks: Decodable {
                    let id: Int
                    let site: String
                    let url: String
                    let type: String
                    let language: String?
                    let color: String?
                    let icon: String?
                    let notes: String?
                    let isDisabled: Bool
                }
                
                struct ReviewPreview: Decodable {
                    let pageInfo: PageInfo
                    let nodes: [Nodes]
                    
                    struct Nodes: Decodable {
                        let id: Int
                        let summary: String
                        let rating: Int
                        let ratingAmount: Int
                        let user: User
                        
                        struct User: Decodable {
                            let id: Int
                            let name: String?
                            let avatar: Avatar?
                            
                            struct Avatar: Decodable {
                                let large: String
                            }
                        }
                    }
                    
                    struct PageInfo: Decodable {
                        let total: Int
                    }
                }
                
                struct Recommendations: Decodable {
                    let pageInfo: PageInfo
                    let nodes: [Nodes]
                    
                    struct Nodes: Decodable {
                        let id: Int
                        let rating: Int?
                        let userRating: String?
                        let mediaRecommendation: MediaRecommendation?
                        let user: User
                        
                        struct User: Decodable {
                            let id: Int
                            let name: String?
                            let avatar: Avatar?
                            
                            struct Avatar: Decodable {
                                let large: String
                            }
                        }
                        
                        struct MediaRecommendation: Decodable {
                            let id: Int
                            let title: Title
                            let format: String?
                            let type: String?
                            let status: String?
                            let bannerImage: String?
                            let coverImage: CoverImage?
                            
                            struct CoverImage: Decodable {
                                let large: String
                            }
                            
                            struct Title: Decodable {
                                let userPreferred: String
                            }
                        }
                    }
                    
                    struct PageInfo: Decodable {
                        let total: Int
                    }
                }
                
                struct Stats: Decodable {
                    let statusDistribution: [StatusDistribution]
                    let scoreDistribution: [ScoreDistribution]
                    
                    struct ScoreDistribution: Decodable {
                        let score: Int
                        let amount: Int
                    }
                    
                    struct StatusDistribution: Decodable {
                        let status: String
                        let amount: Int
                    }
                }
                
                struct StaffPreview: Decodable {
                    var pageInfo: PageInfo
                    var edges: [Edges]
                    
                    struct PageInfo: Decodable {
                        var hasNextPage: Bool
                        var currentPage: Int
                    }
                    
                    struct Edges: Decodable {
                        let id: Int
                        let role: String
                        let node: Node
                        
                        struct Node: Decodable {
                            let id: Int
                            let name: Name
                            let language: String
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
                
                struct CharacterPreview: Decodable {
                    var pageInfo: PageInfo
                    var edges: [Edges]
                    
                    struct PageInfo: Decodable {
                        var currentPage: Int
                        var hasNextPage: Bool
                    }
                    
                    struct Edges: Decodable {
                        let id: Int
                        let role: String
                        let voiceActors: [VoiceActors]
                        let node: Node
                        
                        struct Node: Decodable {
                            let id: Int
                            let name: Name
                            let image: Image
                            
                            struct Image: Decodable {
                                let large: String
                            }
                            
                            struct Name: Decodable {
                                let userPreferred: String
                            }
                        }
                        
                        struct VoiceActors: Decodable {
                            let id: Int
                            let name: Name
                            let language: String
                            let image: Image
                            
                            struct Image: Decodable {
                                let large: String
                            }
                            
                            struct Name: Decodable {
                                let userPreferred: String
                            }
                            
                        }
                    }
                }
                
                
                struct Relations: Decodable {
                    let edges: [Edges]
                    
                    struct Edges: Decodable {
                        let id: Int
                        let relationType: String
                        let node: Node
                        
                        struct Node: Decodable {
                            let id: Int
                            let title: Title
                            let format: String?
                            let type: String?
                            let status: String?
                            let bannerImage: String?
                            let coverImage: CoverImage
                            
                            struct Title: Decodable {
                                let userPreferred: String
                            }
                            struct CoverImage: Decodable {
                                let large: String
                            }
                        }
                        
                    }
                }
                
                
                
                struct Studios: Decodable {
                    let edges: [Edges]
                    
                    struct Edges: Decodable {
                        let isMain: Bool
                        let node: Node
                        
                        struct Node: Decodable {
                            let name: String
                        }
                    }
                }
                
                struct StartDate: Decodable {
                    let year: Int?
                    let month: Int?
                    let day: Int?
                }
                
                struct NextAiringEpisode: Decodable {
                    let airingAt: Int64
                    let timeUntilAiring: Int
                    let episode: Int
                }

                struct MediaTitle: Decodable {
                    let romaji: String?
                    let english: String?
                    let native: String?
                }

                struct MediaCoverImage: Decodable {
                    let extraLarge: String?
                }
                
                struct StreamingEpisodes: Decodable {
                    let site: String
                    let title: String
                    let thumbnail: String
                    let url: String
                }
            }
        }
    }
}
