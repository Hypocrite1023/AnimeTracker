//
//  AnimeFetchData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/16.
//

import Foundation

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


let query = """
query{
    Media(id:$id,type:$type,isAdult:$isAdult){
        id
        title{
            userPreferred
            romaji
            english
            native
        }
        coverImage{
            extraLarge
            large
        }
        bannerImage
        startDate{
            year
            month
            day
        }
        endDate{
            year
            month
            day
        }
        description
        season
        seasonYear
        type
        format
        status(version:2)
        episodes
        duration
        chapters
        volumes
        genres
        synonyms
        source(version:3)
        isAdult
        isLocked
        meanScore
        averageScore
        popularity
        favourites
        isFavouriteBlocked
        hashtag
        countryOfOrigin
        isLicensed
        isFavourite
        isRecommendationBlocked
        isFavouriteBlocked
        isReviewBlocked
        nextAiringEpisode{
            airingAt
            timeUntilAiring
            episode
        }
        relations{
            edges{
                id
                relationType(version:2)
                node{
                    id
                    title{
                        userPreferred
                    }
                    format
                    type
                    status(version:2)
                    bannerImage
                    coverImage{
                        large
                    }
                }
            }
        }
        characterPreview:characters(perPage:6,sort:[ROLE,RELEVANCE,ID]){
            edges{
                id
                role
                name
                voiceActors(language:JAPANESE,sort:[RELEVANCE,ID]){
                    id
                    name{
                        userPreferred
                    }
                    language:languageV2
                    image{
                        large
                    }
                }
                node{
                    id
                    name{
                        userPreferred
                    }
                    image{
                        large
                    }
                }
            }
        }
        staffPreview:staff(perPage:8,sort:[RELEVANCE,ID]){
            edges{
                id
                role
                node{
                    id
                    name{
                        userPreferred
                    }
                    language:languageV2
                    image{
                        large
                    }
                }
            }
        }
        studios{
            edges{
                isMain
                node{
                    id
                    name
                }
            }
        }
        reviewPreview:reviews(perPage:2,sort:[RATING_DESC,ID]){
            pageInfo{
                total
            }
            nodes{
                id
                summary
                rating
                ratingAmount
                user{
                    id
                    name
                    avatar{
                        large
                    }
                }
            }
        }
        recommendations(perPage:7,sort:[RATING_DESC,ID]){
            pageInfo{
                total
            }
            nodes{
                id
                rating
                userRating
                mediaRecommendation{
                    id
                    title{
                        userPreferred
                    }
                    format
                    type
                    status(version:2)
                    bannerImage
                    coverImage{
                        large
                    }
                }
                user{
                    id
                    name
                    avatar{
                        large
                    }
                }
            }
        }
        externalLinks{
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
        streamingEpisodes{
            site
            title
            thumbnail
            url
        }
        trailer{
            id
            site
        }
        rankings{
            id
            rank
            type
            format
            year
            season
            allTime
            context
        }
        tags{
            id
            name
            description
            rank
            isMediaSpoiler
            isGeneralSpoiler
            userId
        }
        mediaListEntry{
            id
            status
            score
        }
        stats{
            statusDistribution{
                status
                amount
            }
            scoreDistribution{
                score
                amount
            }
        }
    }
}
"""


struct MediaResponse: Decodable {
    let data: MediaData

    struct MediaData: Decodable {
        let media: Media

        enum CodingKeys: String, CodingKey {
            case media = "Media"
        }

        // airing, format, episodes, episode duration, status, start date, season, average score, mean score, popularity, favorites, studios, producers, source, hashtag, genres, romaji, english, native, synonyms
        struct Media: Decodable {
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
            let characterPreview: CharacterPreview
            let staffPreview: StaffPreview
            let stats: Stats
            let recommendations: Recommendations
            let reviewPreview: ReviewPreview
            
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
                let edges: [Edges]
                
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
                let edges: [Edges]
                
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
    var trendingNextFetchPage = 1
    var isFetchingData = false
    
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
        staffPreview: staff(perPage: 8,sort: [RELEVANCE,ID]) {
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
                print(media.data.media.streamingEpisodes)
                self.animeDetailDataDelegate?.animeDetailDataDelegate(media: media.data.media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
}
