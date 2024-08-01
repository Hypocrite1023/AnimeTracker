//
//  AnimeFetchData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/16.
//

import Foundation
import Combine

struct AnimeSearchedOrTrending: Codable {
    var data: Page
    
    struct Page: Codable {
        var Page: PageInfoAndMedia
    }
    struct PageInfoAndMedia: Codable {
        var media: [Anime]
        let pageInfo: PageInfo
    }
    struct Anime: Codable {
        let id: Int
        let title: Title
        let coverImage: CoverImage
    }
    struct PageInfo: Codable {
        let hasNextPage: Bool
    }
    struct Title: Codable {
        let native: String
    }
    struct CoverImage: Codable {
        let extraLarge: String
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
                        let coverImage: MediaResponse.MediaData.Media.MediaCoverImage
                        let startDate: StartDate
                        let mediaListEntry: MediaListEntry?
                        
                        struct MediaListEntry: Decodable {
                            let id: Int
                            let status: String?
                        }
                        
                        struct StartDate: Decodable {
                            let year: Int
                        }
                        
                        struct Title: Decodable {
                            let userPreferred: String
                        }
                    }
                    
                    struct VoiceActorRoles: Decodable {
                        let roleNotes: String?
                        let voiceActor: MediaResponse.MediaData.Media.CharacterPreview.Edges.VoiceActors
                        
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

struct MediaStaffPreview: Decodable {
    let data: MediaData

    struct MediaData: Decodable {
        let media: Media
        
        enum CodingKeys: String, CodingKey {
            case media = "Media"
        }
        struct Media: Decodable {
            let staffPreview: MediaResponse.MediaData.Media.StaffPreview
        }
    }
}

struct MediaCharacterPreview: Decodable {
    let data: MediaData

    struct MediaData: Decodable {
        let media: Media
        
        enum CodingKeys: String, CodingKey {
            case media = "Media"
        }
        struct Media: Decodable {
            let characterPreview: MediaResponse.MediaData.Media.CharacterPreview
        }
    }
}
// MARK: - MediaResponse struct
struct MediaResponse: Decodable {
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
            let coverImage: MediaCoverImage
            
            let seasonYear: Int
            let season: String
            
            let description: String
            let streamingEpisodes: [StreamingEpisodes]
            let bannerImage: String?
            let nextAiringEpisode: NextAiringEpisode?
            let format: String
            let episodes: Int?
            let duration: Int // min
            let status: String
            let startDate: StartDate
            let averageScore: Int
            let meanScore: Int
            let popularity: Int
            let favourites: Int
            let studios: Studios // also contain producers
            let source: String
            let hashtag: String
            let genres: [String]
            let synonyms: [String]
            let relations: Relations?
            var characterPreview: CharacterPreview
            var staffPreview: StaffPreview
            let stats: Stats
            let recommendations: Recommendations
            let reviewPreview: ReviewPreview
            let externalLinks: [ExternalLinks]
            let tags: [Tag]
            
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
                let year: Int
                let month: Int
                let day: Int
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

class AnimeFetchData {
    // trending
    // anime image, anime title
    let queryURL = URL(string: "https://graphql.anilist.co")!
    var animeDataDelegateManager: AnimeDataDelegate?
    var animeDetailDataDelegate: AnimeDetailDataDelegate?
    var animeCharacterDataDelegate: AnimeCharacterDataDelegate?
    var trendingNextFetchPage = 1
    @Published var isFetchingData = false
    
    func fetchAnimeBySearch(year: String, season: String) {
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
            query {
              Page(page: 1, perPage: 50) {
                media(type: ANIME, seasonYear: \(year), season: \(season)) {
                  # id
                  title {
                    romaji
                    english
                    native
                  }
                  # episodes
                  coverImage {
                    extraLarge
                  }
                  # season
                }
                pageInfo {
                  hasNextPage
                }
              }
            }
            """
        // Set GraphQL query data
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
//            print(String(data: data, encoding: .utf8))
            do {
                let media = try JSONDecoder().decode(AnimeSearchedOrTrending.self, from: data)
                self.animeDataDelegateManager?.passAnimeData(animeData: media)
//                print(media.data.Page.first?.media.coverImage)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
        
    }
    
    func fetchAnimeByTrending(page: Int) {
        isFetchingData = true
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
            query {
              Page(page: \(page), perPage: 50) {
                media(sort: TRENDING_DESC, type: ANIME) {
                  id
                  title {
                    native
                  }
                  coverImage {
                    extraLarge
                  }
                }
                pageInfo {
                  hasNextPage
                }
              }
            }
            """
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
//            print(String(data: data, encoding: .utf8))
            do {
                let media = try JSONDecoder().decode(AnimeSearchedOrTrending.self, from: data)
                self.animeDataDelegateManager?.passAnimeData(animeData: media)
                self.trendingNextFetchPage += 1
//                print(media.data.Page.first?.media.coverImage)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchAnimeByID(id: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
    Media(id: \(id)) {
        id
        title {
            romaji
            english
            native
        }
        coverImage {
            extraLarge
        }
        seasonYear
        season
        description
        streamingEpisodes {
            site
            title
            thumbnail
            url
        }
        streamingEpisodes {
            site
            title
            thumbnail
            url
        }
        bannerImage
        nextAiringEpisode {
            airingAt
            timeUntilAiring
            episode
        }
        format
        episodes
        duration
        status
        startDate {
            year
            month
            day
        }
        averageScore
        meanScore
        popularity
        favourites
        studios {
            edges {
                isMain
                node {
                    name
                }
            }
        }
        source
        hashtag
        genres
        synonyms
        relations {
            edges {
                id
                relationType(version: 2)
                node {
                    id
                    title {
                        userPreferred
                    }
                    format
                    type
                    status(version: 2)
                    bannerImage
                    coverImage {
                        large
                    }
                }
            }
        }
        characterPreview:characters(perPage: 6,sort: [ROLE,RELEVANCE,ID]) {
            pageInfo {
                currentPage
                hasNextPage
            }
            edges {
                id
                role
                name
                voiceActors(language: JAPANESE,sort: [RELEVANCE,ID]) {
                    id
                    name {
                        userPreferred
                    }
                    language: languageV2
                    image {
                        large
                    }
                }
                node {
                    id
                    name {
                        userPreferred
                    }
                    image {
                        large
                    }
                }
            }
        }
        staffPreview: staff(perPage: 6, page: 1,sort: [RELEVANCE,ID]) {
            pageInfo {
                hasNextPage
                currentPage
            }
            edges {
                id
                role
                node {
                    id
                    name {
                        userPreferred
                    }
                    language: languageV2
                    image {
                        large
                    }
                }
            }
        }
        stats {
            statusDistribution {
                status
                amount
            }
            scoreDistribution {
                score
                amount
            }
        }
        recommendations(perPage: 7,sort: [RATING_DESC,ID]) {
            pageInfo {
                total
            }
            nodes {
                id
                rating
                userRating
                mediaRecommendation {
                    id
                    title {
                        userPreferred
                    }
                    format
                    type
                    status(version:2)
                    bannerImage
                    coverImage {
                        large
                    }
                }
                user {
                    id
                    name
                    avatar {
                        large
                    }
                }
            }
        }
        reviewPreview: reviews(perPage: 2,sort: [RATING_DESC,ID]) {
            pageInfo {
                total
            }
            nodes {
                id
                summary
                rating
                ratingAmount
                user {
                    id
                    name
                    avatar{
                        large
                    }
                }
            }
        }
        externalLinks {
            id
            site
            url
            type
            language
            color
            icon
            notes
            isDisabled
        }
        tags {
            id
            name
            description
            rank
            isMediaSpoiler
            isGeneralSpoiler
            userId
        }
    }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let media = try JSONDecoder().decode(MediaResponse.self, from: data)
//                print(media.data.media.characterPreview.pageInfo.currentPage, "currentPage")
                self.animeDetailDataDelegate?.animeDetailDataDelegate(media: media.data.media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchCharacterPreviewByMediaId(id: Int, page: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
    Media(id: \(id)) {
        characterPreview:characters(perPage: 6, page: \(page), sort: [ROLE, RELEVANCE, ID]) {
            pageInfo {
                currentPage
                hasNextPage
            }
            edges {
                id
                role
                voiceActors(language: JAPANESE, sort: [RELEVANCE, ID]) {
                    id
                    name {
                        userPreferred
                    }
                    language: languageV2
                    image {
                        large
                    }
                }
                node {
                    id
                    name {
                        userPreferred
                    }
                    image {
                        large
                    }
                }
            }
        }
    }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let media = try JSONDecoder().decode(MediaCharacterPreview.self, from: data)
//                print(media.data.media.characterPreview.pageInfo.currentPage, "currentPage")
                self.animeDetailDataDelegate?.animeDetailCharacterDataDelegate(characterData: media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchStaffPreviewByMediaId(id: Int, page: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
    Media(id: \(id)) {
        staffPreview: staff(perPage: 6, page: \(page), sort: [RELEVANCE, ID]) {
            pageInfo {
                hasNextPage
                currentPage
            }
            edges {
                id
                role
                node {
                    id
                    name {
                        userPreferred
                    }
                    language: languageV2
                    image {
                        large
                    }
                }
            }
        }
    }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let media = try JSONDecoder().decode(MediaStaffPreview.self, from: data)
                self.animeDetailDataDelegate?.animeDetailStaffDataDelegate(staffData: media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchRankingDataByMediaId(id: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
    Media(id: \(id)) {
        rankings {
            rank
            type
            format
            year
            season
            allTime
            context
        }
    }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let media = try JSONDecoder().decode(MediaRanking.self, from: data)
                self.animeDetailDataDelegate?.animeDetailRankingDataDelegate(rankingData: media.data.media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchThreadDataByMediaId(id: Int, page: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
  Page(page: \(page), perPage: 10) {
    pageInfo {
      total
      perPage
      currentPage
      lastPage
      hasNextPage
    }
    threads(mediaCategoryId: \(id), sort: ID_DESC) {
      id
      title
      replyCount
      viewCount
      replyCommentId
      repliedAt
      createdAt
      categories {
        id
        name
      }
      user {
        id
        name
        avatar {
          large
        }
      }
      replyUser {
        id
        name
        avatar {
          large
        }
      }
    }
  }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            do {
                let media = try JSONDecoder().decode(ThreadResponse.self, from: data)
                self.animeDetailDataDelegate?.animeDetailThreadDataDelegate(threadData: media.data)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchCharacterDetailByCharacterID(id: Int, page: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query{
  Character(id: \(id)) {
    id
    name {
      first
      middle
      last
      full
      native
      userPreferred
      alternative
      alternativeSpoiler
    }
    image{
      large
    }
    favourites
    isFavourite
    isFavouriteBlocked
    description(asHtml: true)
    age
    gender
    bloodType
    dateOfBirth {
      year
      month
      day
    }
    media(page: \(page), sort: POPULARITY_DESC, onList: true)@include(if: true) {
      pageInfo {
        total
        perPage
        currentPage
        lastPage
        hasNextPage
      }
      edges {
        id
        characterRole
        voiceActorRoles(sort:[RELEVANCE,ID]) {
          roleNotes
          voiceActor {
            id
            name {
              userPreferred
            }
            image {
              large
            }
            language:languageV2
          }
        }
        node {
          id
          type
          isAdult
          bannerImage
          title {
            userPreferred
          }
          coverImage {
            extraLarge
          }
          startDate {
            year
          }
          mediaListEntry {
            id
            status
          }
        }
      }
    }
  }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
            return
        }
        // Create URLSession task
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            do {
//                print(String(data: data, encoding: .utf8))
                let media = try JSONDecoder().decode(CharacterDetail.self, from: data)
                self.animeCharacterDataDelegate?.animeCharacterDataDelegate(characterData: media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
}
//query($id:Int) {
//  Media(id:$id) {
//    id
//    trends(sort: ID_DESC) {
//      nodes {
//        averageScore
//        date
//        trending
//        popularity
//      }
//    }
//    airingTrends: trends(releasing: true, sort: EPISODE_DESC) {
//      nodes {
//        averageScore
//        inProgress
//        episode
//      }
//    }
//  }
//}
