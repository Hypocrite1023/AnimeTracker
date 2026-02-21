//
//  Response+Anime.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation

extension Response {
    typealias AnimeTrending = AnimeSummary
    typealias AnimeCategory = AnimeSummary
    typealias AnimeSearching = AnimeSummary
    
    struct AnimeSummary: Decodable {
        var data: Page
        
        struct Page: Decodable {
            var page: PageInfoAndMedia
            
            enum CodingKeys: String, CodingKey {
                case page = "Page"
            }
            
            struct PageInfoAndMedia: Decodable {
                var media: [AnimeEssentialData]
                var pageInfo: PageInfo
                
                struct PageInfo: Decodable {
                    var currentPage: Int
                    var hasNextPage: Bool
                }
            }
        }
    }
    
    struct AnimeEssentialData: Decodable {
        let id: Int
        let title: Title
        let coverImage: CoverImage?
        let status: String?
        var statusInfo: AnimeStatus {
            AnimeStatus(rawValue: status ?? "") ?? .unknown
        }
        
        struct Title: Codable {
            let native: String?
            let english: String?
            let romaji: String?
        }
        
        struct CoverImage: Codable {
            let extraLarge: String
        }
    }
    
    struct AnimeDetail: Decodable {
        let data: MediaData

        struct MediaData: Decodable {
            let media: Media

            enum CodingKeys: String, CodingKey {
                case media = "Media"
            }

            // airing, format, episodes, episode duration, status, start date, season, average score, mean score, popularity, favorites, studios, producers, source, hashtag, genres, romaji, english, native, synonyms
            struct Media: Decodable {
                /// The unique identifier of the media. (e.g., `88369`)
                let id: Int
                /// The official titles of the media in various languages.
                let title: MediaTitle
                /// The cover image of the media.
                let coverImage: MediaCoverImage?
                
                /// The season year the media was released.
                let seasonYear: Int?
                /// The season the media was released (e.g., `SPRING`, `SUMMER`, `FALL`, `WINTER`).
                let season: String?
                
                /// Short description of the media's story and characters.
                let description: String?
                /// List of streaming episodes available.
                let streamingEpisodes: [StreamingEpisodes]
                /// The banner image of the media.
                let bannerImage: String?
                /// The next episode to air.
                let nextAiringEpisode: NextAiringEpisode?
                /// The format of the media (e.g., `TV`, `MOVIE`, `OVA`, `NOVEL`).
                let format: String?
                /// The amount of episodes the anime has when complete.
                let episodes: Int?
                /// The general length of each episode in minutes.
                let duration: Int? // minute
                /// The current releasing status of the media. (e.g., `FINISHED`, `RELEASING`, `NOT_YET_RELEASED`, `CANCELLED`).
                let status: String?
                /// The first official release date of the media.
                let startDate: StartDate?
                /// A weighted average score of all the user's scores of the media.
                let averageScore: Int?
                /// Mean score of all the user's scores of the media.
                let meanScore: Int?
                /// The number of users with the media on their list.
                let popularity: Int?
                /// The number of users that have favourited the media.
                let favourites: Int?
                /// The companies that produced the anime.
                let studios: Studios? // also contain producers
                /// Source type the media was adapted from (e.g., `ORIGINAL`, `MANGA`, `LIGHT_NOVEL`).
                let source: String?
                /// Official Twitter hashtags for the media.
                let hashtag: String?
                /// List of genres of the media.
                let genres: [String]?
                /// Alternative titles of the media.
                let synonyms: [String]?
                /// Other media in the same franchise.
                let relations: Relations?
                /// Preview of characters in the media.
                var characterPreview: CharacterPreview?
                /// Preview of staff that worked on the media.
                var staffPreview: StaffPreview?
                /// Status and score distribution statistics.
                let stats: Stats?
                /// User recommendations for similar media.
                let recommendations: Recommendations?
                /// Preview of reviews for the media.
                let reviewPreview: ReviewPreview?
                /// External links to another site related to the media.
                let externalLinks: [ExternalLinks]?
                /// List of tags that describes elements and themes of the media.
                let tags: [Tag]?
                
                struct Tag: Decodable {
                    /// The id of the tag.
                    let id: Int
                    /// The name of the tag.
                    let name: String
                    /// A description of the tag.
                    let description: String?
                    /// The relevance rank of the tag.
                    let rank: Int
                    /// If the tag spoils the media.
                    let isMediaSpoiler: Bool
                    /// If the tag is a general spoiler.
                    let isGeneralSpoiler: Bool
                    /// The user who added the tag.
                    let userId: Int?
                }
                
                struct ExternalLinks: Decodable {
                    /// The id of the link.
                    let id: Int
                    /// The site name.
                    let site: String
                    /// The URL.
                    let url: String
                    /// The type of link.
                    let type: String
                    /// The language of the site.
                    let language: String?
                    /// The color associated with the site.
                    let color: String?
                    /// The icon URL.
                    let icon: String?
                    /// Any notes.
                    let notes: String?
                    /// Whether the link is disabled.
                    let isDisabled: Bool
                }
                
                struct ReviewPreview: Decodable {
                    /// Page info for reviews.
                    let pageInfo: PageInfo
                    /// List of review nodes.
                    let nodes: [Nodes]
                    
                    struct Nodes: Decodable {
                        /// Review ID.
                        let id: Int
                        /// Review summary.
                        let summary: String
                        /// Review rating.
                        let rating: Int
                        /// Number of ratings.
                        let ratingAmount: Int
                        /// User who wrote the review.
                        let user: User
                        
                        struct User: Decodable {
                            /// User ID.
                            let id: Int
                            /// User name.
                            let name: String?
                            /// User avatar.
                            let avatar: Avatar?
                            
                            struct Avatar: Decodable {
                                /// Large avatar URL.
                                let large: String
                            }
                        }
                    }
                    
                    struct PageInfo: Decodable {
                        /// Total reviews.
                        let total: Int
                    }
                }
                
                struct Recommendations: Decodable {
                    /// Page info for recommendations.
                    let pageInfo: PageInfo
                    /// List of recommendation nodes.
                    let nodes: [Nodes]
                    
                    struct Nodes: Decodable {
                        /// Recommendation ID.
                        let id: Int
                        /// Rating.
                        let rating: Int?
                        /// User rating.
                        let userRating: String?
                        /// The recommended media.
                        let mediaRecommendation: MediaRecommendation?
                        /// User who made the recommendation.
                        let user: User
                        
                        struct User: Decodable {
                            /// User ID.
                            let id: Int
                            /// User name.
                            let name: String?
                            /// User avatar.
                            let avatar: Avatar?
                            
                            struct Avatar: Decodable {
                                /// Large avatar URL.
                                let large: String
                            }
                        }
                        
                        struct MediaRecommendation: Decodable {
                            /// Media ID.
                            let id: Int
                            /// Media title.
                            let title: Title
                            /// Media format.
                            let format: String?
                            /// Media type.
                            let type: String?
                            /// Media status.
                            let status: String?
                            /// Banner image URL.
                            let bannerImage: String?
                            /// Cover image.
                            let coverImage: CoverImage?
                            
                            struct CoverImage: Decodable {
                                /// Large cover image URL.
                                let large: String
                            }
                            
                            struct Title: Decodable {
                                /// User preferred title.
                                let userPreferred: String
                            }
                        }
                    }
                    
                    struct PageInfo: Decodable {
                        /// Total recommendations.
                        let total: Int
                    }
                }
                
                struct Stats: Decodable {
                    /// Distribution of user statuses.
                    let statusDistribution: [StatusDistribution]
                    /// Distribution of scores.
                    let scoreDistribution: [ScoreDistribution]
                    
                    struct ScoreDistribution: Decodable {
                        /// The score (10-100).
                        let score: Int
                        /// Amount of users who gave this score.
                        let amount: Int
                    }
                    
                    struct StatusDistribution: Decodable {
                        /// The status (e.g. Completed, Dropped).
                        let status: String
                        /// Amount of users with this status.
                        let amount: Int
                    }
                }
                
                struct StaffPreview: Decodable {
                    /// Page info for staff preview.
                    var pageInfo: PageInfo
                    /// List of staff edges.
                    var edges: [Edges]
                    
                    struct PageInfo: Decodable {
                        /// If there is a next page.
                        var hasNextPage: Bool
                        /// Current page number.
                        var currentPage: Int
                    }
                    
                    struct Edges: Decodable {
                        /// Edge ID.
                        let id: Int
                        /// Role of the staff member.
                        let role: String
                        /// The staff node.
                        let node: Node
                        
                        struct Node: Decodable {
                            /// Staff ID.
                            let id: Int
                            /// Staff name.
                            let name: Name
                            /// Staff language.
                            let language: String
                            /// Staff image.
                            let image: Image
                            
                            struct Name: Decodable {
                                /// User preferred name.
                                let userPreferred: String
                                
                            }
                            
                            struct Image: Decodable {
                                /// Large image URL.
                                let large: String
                            }
                        }
                    }
                    
                }
                
                struct CharacterPreview: Decodable {
                    /// Page info for character preview.
                    var pageInfo: PageInfo
                    /// List of character edges.
                    var edges: [Edges]
                    
                    struct PageInfo: Decodable {
                        /// Current page number.
                        var currentPage: Int
                        /// If there is a next page.
                        var hasNextPage: Bool
                    }
                    
                    struct Edges: Decodable {
                        /// Edge ID.
                        let id: Int
                        /// Role of the character (e.g. MAIN, SUPPORTING).
                        let role: String
                        /// Voice actors associated with the character.
                        let voiceActors: [VoiceActors]
                        /// The character node.
                        let node: Node
                        
                        struct Node: Decodable {
                            /// Character ID.
                            let id: Int
                            /// Character name.
                            let name: Name
                            /// Character image.
                            let image: Image
                            
                            struct Image: Decodable {
                                /// Large image URL.
                                let large: String
                            }
                            
                            struct Name: Decodable {
                                /// User preferred name.
                                let userPreferred: String
                            }
                        }
                        
                        struct VoiceActors: Decodable {
                            /// Voice actor ID.
                            let id: Int
                            /// Voice actor name.
                            let name: Name
                            /// Voice actor language.
                            let language: String
                            /// Voice actor image.
                            let image: Image
                            
                            struct Image: Decodable {
                                /// Large image URL.
                                let large: String
                            }
                            
                            struct Name: Decodable {
                                /// User preferred name.
                                let userPreferred: String
                            }
                            
                        }
                    }
                }
                
                
                struct Relations: Decodable {
                    /// List of relation edges.
                    let edges: [Edges]
                    
                    struct Edges: Decodable {
                        /// Edge ID.
                        let id: Int
                        /// The type of relation (e.g. SEQUEL, PREQUEL).
                        let relationType: String
                        /// The related media node.
                        let node: Node
                        
                        struct Node: Decodable {
                            /// Media ID.
                            let id: Int
                            /// Media title.
                            let title: Title
                            /// Media format.
                            let format: String?
                            /// Media type.
                            let type: String?
                            /// Media status.
                            let status: String?
                            /// Banner image URL.
                            let bannerImage: String?
                            /// Cover image.
                            let coverImage: CoverImage
                            
                            struct Title: Decodable {
                                /// User preferred title.
                                let userPreferred: String
                            }
                            struct CoverImage: Decodable {
                                /// Large cover image URL.
                                let large: String
                            }
                        }
                        
                    }
                }
                
                
                
                struct Studios: Decodable {
                    /// List of studio edges.
                    let edges: [Edges]
                    
                    struct Edges: Decodable {
                        /// If this is the main studio.
                        let isMain: Bool
                        /// The studio node.
                        let node: Node
                        
                        struct Node: Decodable {
                            /// Studio name.
                            let name: String
                        }
                    }
                }
                
                struct StartDate: Decodable {
                    /// Year of release.
                    let year: Int?
                    /// Month of release.
                    let month: Int?
                    /// Day of release.
                    let day: Int?
                }
                
                struct NextAiringEpisode: Decodable {
                    /// Timestamp when the episode will air.
                    let airingAt: Int64
                    /// Seconds until the episode airs.
                    let timeUntilAiring: Int
                    /// The episode number.
                    let episode: Int
                }

                struct MediaTitle: Decodable {
                    /// The romanized Japanese title.
                    let romaji: String?
                    /// The official English title.
                    let english: String?
                    /// The official native title.
                    let native: String?
                }

                struct MediaCoverImage: Decodable {
                    /// The URL for the extra large cover image.
                    let extraLarge: String?
                }
                
                struct StreamingEpisodes: Decodable {
                    /// The site where the stream is hosted.
                    let site: String
                    /// The title of the episode.
                    let title: String
                    /// The URL for the thumbnail image.
                    let thumbnail: String
                    /// The URL to watch the episode.
                    let url: String
                }
            }
        }
    }
    
    struct SimpleEpisodeData: Decodable {
        let data: DataResponse
        
        struct DataResponse: Decodable {
            let Media: SimpleMedia
            
            struct SimpleMedia: Decodable {
                let id: Int
                let title: Title
                let nextAiringEpisode: NextAiringEpisode?
                let episodes: Int?
                let coverImage: CoverImage
                let status: String
                var statusInfo: Response.AnimeStatus {
                    Response.AnimeStatus(rawValue: status) ?? .unknown
                }
                
                struct Title: Decodable {
                    let native: String
                    let romaji: String?
                    let english: String?
                }
                
                struct NextAiringEpisode: Decodable {
                    let episode: Int
                    let timeUntilAiring: Int
                }
                
                struct CoverImage: Decodable {
                    let large: String
                }
            }
        }
    }
    
    struct AnimeTimeLineInfo: Decodable {
        let data: DataResponse
        
        struct DataResponse: Decodable {
            let Media: SimpleMedia
            
            struct SimpleMedia: Decodable {
                let id: Int
                let title: Title
                let nextAiringEpisode: NextAiringEpisode?
                let episodes: Int?
                
                struct Title: Decodable {
                    let native: String
                    let romaji: String?
                    let english: String?
                }
                
                struct NextAiringEpisode: Decodable {
                    let episode: Int
                    let timeUntilAiring: Int
                }
            }
        }
    }
    
    struct DynamicSimpleAnimeDataResponse: Decodable {
        let data: [String: AnimeEssentialData]
    }
    
    struct DynamicSimpleEpisodeDataResponse: Decodable {
        let data: [String: SimpleEpisodeData.DataResponse.SimpleMedia]
    }
    
    struct EssentialDataCollection: Decodable {
        let data: EssentialData
        
        struct EssentialData: Decodable {
            let genreCollection: [String]
            let externalLinkSourceCollection: [ExternalLinkSourceCollection]
            
            struct ExternalLinkSourceCollection: Decodable {
                let site: String
            }
        }
    }
    
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
    
    struct AnimeSearchingResult: Decodable {
        var data: Page
        
        struct Page: Decodable {
            var Page: PageInfoAndMedia
            
            struct PageInfoAndMedia: Decodable {
                var media: [AnimeEssentialData]
                var pageInfo: PageInfo
                
                struct Anime: Decodable {
                    let id: Int
                    let title: Title
                    let coverImage: CoverImage
                    
                    struct Title: Decodable {
                        let native: String?
                        let english: String?
                        let romaji: String?
                    }
                    struct CoverImage: Decodable {
                        let extraLarge: String
                    }
                }
                struct PageInfo: Decodable {
                    var currentPage: Int
                    var hasNextPage: Bool
                }
            }
        }
    }
    
    struct AnimeSearchResult<T: Decodable>: Decodable {
        var data: Page
        
        struct Page: Decodable {
            var Page: PageInfoAndMedia
            
            struct PageInfoAndMedia: Decodable {
                var media: [T]
                var pageInfo: PageInfo
                
                struct PageInfo: Decodable {
                    var currentPage: Int
                    var hasNextPage: Bool
                }
            }
        }
    }
    
    struct AnimeTimelineData: Decodable {
        let id: Int
        let title: Title
        let coverImage: CoverImage?
        let status: String?
        let nextAiringEpisode: NextAiringEpisode?
        var statusInfo: AnimeStatus {
            AnimeStatus(rawValue: status ?? "") ?? .unknown
        }
        
        struct Title: Codable {
            let native: String?
            let english: String?
            let romaji: String?
        }
        
        struct CoverImage: Codable {
            let extraLarge: String
        }
        
        struct NextAiringEpisode: Decodable {
            let episode: Int?
            let timeUntilAiring: Int?
            let airingAt: Int?
        }
    }
    
    struct AnimeCategoryResult: Decodable {
        var data: [String: Media]
        struct Media: Decodable {
            let media: [Anime]
        }
        
        struct Anime: Decodable {
            let id: Int
            let title: Title
            let coverImage: CoverImage
            
            struct Title: Decodable {
                let native: String?
                let english: String?
                let romaji: String?
            }
            
            struct CoverImage: Decodable {
                let large: String
            }
        }
    }
    
    // Wrapper for simple media response
    struct SimpleMediaResponse: Decodable {
        let data: DataStruct
        struct DataStruct: Decodable {
            let Media: Response.AnimeEssentialData
        }
    }
}

// MARK: - Anime status
extension Response {
    enum AnimeStatus: String {
        case airing = "RELEASING"
        case finished = "FINISHED"
        case upcoming = "NOT_YET_RELEASED"
        case cancelled = "CANCELLED"
        case unknown = ""
    }
}
