//
//  AnimeFetchData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/16.
//

import Foundation
import Combine

struct SimpleAnimeData: Codable {
    let data: DataResponse
    
    struct DataResponse: Codable {
        let Media: SimpleMedia
        
        struct SimpleMedia: Codable {
            let id: Int
            let title: Title
            let coverImage: CoverImage
            let status: String
            
            struct Title: Codable {
                let native: String
                let romaji: String?
                let english: String?
            }
            struct CoverImage: Codable {
                let large: String
            }
        }
    }
}

struct SimpleEpisodeData: Codable {
    let data: DataResponse
    
    struct DataResponse: Codable {
        let Media: SimpleMedia
        
        struct SimpleMedia: Codable {
            let id: Int
            let title: Title
            let nextAiringEpisode: NextAiringEpisode?
            let episodes: Int?
            let coverImage: CoverImage
            
            struct Title: Codable {
                let native: String
                let romaji: String?
                let english: String?
            }
            
            struct NextAiringEpisode: Codable {
                let episode: Int
                let timeUntilAiring: Int
            }
            
            struct CoverImage: Codable {
                let large: String
            }
        }
    }
}

struct AnimeTimeLineInfo: Codable {
    let data: DataResponse
    
    struct DataResponse: Codable {
        let Media: SimpleMedia
        
        struct SimpleMedia: Codable {
            let id: Int
            let title: Title
            let nextAiringEpisode: NextAiringEpisode?
            let episodes: Int?
            
            struct Title: Codable {
                let native: String
                let romaji: String?
                let english: String?
            }
            
            struct NextAiringEpisode: Codable {
                let episode: Int
                let timeUntilAiring: Int
            }
        }
    }
}

struct DynamicSimpleAnimeDataResponse: Codable {
    let data: [String: SimpleAnimeData.DataResponse.SimpleMedia]
}

struct DynamicSimpleEpisodeDataResponse: Codable {
    let data: [String: SimpleEpisodeData.DataResponse.SimpleMedia]
}

struct EssentialDataCollection: Codable {
    let data: EssentialData
    
    struct EssentialData: Codable {
        let GenreCollection: [String]
    }
}

class AnimeDataFetcher {
    
    static let shared = AnimeDataFetcher()
    
    var queryURL: URL!
    weak var animeDataDelegateManager: AnimeDataDelegate?
    weak var animeOverViewDataDelegate: AnimeOverViewDataDelegate?
    weak var animeDetailDataDelegate: AnimeDetailDataDelegate?
    weak var animeCharacterDataDelegate: AnimeCharacterDataDelegate?
    weak var animeVoiceActorDataDelegate: AnimeVoiceActorDataDelegate?
    weak var passMoreVoiceActorData: ReceiveMoreVoiceActorData?
    var trendingNextFetchPage = 1
    @Published var isFetchingData = false
    
    private init() {
        self.queryURL = URL(string: "https://graphql.anilist.co")!
    }
    
    func fetchAnimeBySearch(year: String, season: String) {
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
            query {
              Page(page: 1, perPage: 50) {
                media(type: ANIME, seasonYear: \(year), season: \(season), sort: POPULARITY_DESC) {
                  id
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
                  currentPage
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
                  currentPage
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
//                self.animeDetailDataDelegate?.animeDetailDataDelegate(media: media.data.media)
                self.animeOverViewDataDelegate?.animeDetailDataDelegate(media: media.data.media)
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
    
    func fetchVoiceActorDataByID(id: Int, page: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
  Staff(id: \(id)) {
    id
    name {
      first
      middle
      last
      full
      native
      userPreferred
      alternative
    }
    image {
      large
    }
    description(asHtml:true)
    favourites
    isFavourite
    isFavouriteBlocked
    age
    gender
    yearsActive
    homeTown
    bloodType
    primaryOccupations
    dateOfBirth {
      year
      month
      day
    }
    dateOfDeath {
      year
      month
      day
    }
    language: languageV2
    characterMedia(page: \(page), perPage: 50, sort: START_DATE_DESC, onList: false) @include (if: true) {
      pageInfo {
        total
        perPage
        currentPage
        lastPage
        hasNextPage
      }
      edges {
        characterRole
        characterName
        node {
          id
          type
          bannerImage
          isAdult
          title {
            userPreferred
          }
          coverImage {
            large
          }
          startDate {
            year
          }
          mediaListEntry {
            id
            status
          }
        }
        characters {
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
    staffMedia(page: \(page), perPage: 10, sort: ID_DESC, onList: false) @include (if: true) {
      pageInfo {
        total
        perPage
        currentPage
        lastPage
        hasNextPage
      }
      edges {
        staffRole
        node {
          id
          type
          isAdult
          title {
            userPreferred
          }
          coverImage {
            large
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
                let media = try JSONDecoder().decode(VoiceActorDataResponse.self, from: data)
                self.animeVoiceActorDataDelegate?.animeVoiceActorDataDelegate(voiceActorData: media.data.Staff)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchMoreVoiceActorDataByID(id: Int, page: Int) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
  Staff(id: \(id)) {
    characterMedia(page: \(page), perPage: 50, sort: START_DATE_DESC, onList: false) @include (if: true) {
      pageInfo {
        total
        perPage
        currentPage
        lastPage
        hasNextPage
      }
      edges {
        characterRole
        characterName
        node {
          id
          type
          bannerImage
          isAdult
          title {
            userPreferred
          }
          coverImage {
            large
          }
          startDate {
            year
          }
          mediaListEntry {
            id
            status
          }
        }
        characters {
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
//                print(String(data: data, encoding: .utf8))
                let media = try JSONDecoder().decode(VoiceActorData.self, from: data)
                self.passMoreVoiceActorData?.updateVoiceActorData(voiceActorData: media.data.Staff.characterMedia)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchAnimeSimpleDataByID(id: Int, completion: @escaping (SimpleAnimeData?) -> Void) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
  Media(id: \(id)) {
    title {
      native
      romaji
      english
    }
    coverImage {
      large
    }
    status
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
                let media = try JSONDecoder().decode(SimpleAnimeData.self, from: data)
                completion(media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchAnimeSimpleDataByIDs(id: [Int], completion: @escaping ([SimpleAnimeData.DataResponse.SimpleMedia?]) -> Void) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var query = ""
        for (index, animeID) in id.enumerated() {
            query += """
          anime\(index): Media(id: \(animeID)) {
            id
            title {
              native
              romaji
              english
            }
            coverImage {
              large
            }
            status
          }
        """
        }
        
        query = "{ \(query) }"
//        print(query)
        
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
                let media = try JSONDecoder().decode(DynamicSimpleAnimeDataResponse.self, from: data)
                let mediaDictionary = Dictionary(uniqueKeysWithValues: media.data.map { ($0.value.id, $0.value) })

                // Create the result array based on the original idArray order
                let orderedMediaArray: [SimpleAnimeData.DataResponse.SimpleMedia] = id.compactMap { mediaDictionary[$0] }
                
                completion(orderedMediaArray)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchAnimeEpisodeDataByID(id: Int, completion: @escaping (SimpleEpisodeData?) -> Void) {
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
      native
      romaji
      english
    }
    nextAiringEpisode {
      episode
      timeUntilAiring
    }
    episodes
    coverImage {
      large
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
                let media = try JSONDecoder().decode(SimpleEpisodeData.self, from: data)
                completion(media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchAnimeEpisodeDataByIDs(id: [Int], completion: @escaping ([SimpleEpisodeData.DataResponse.SimpleMedia?]) -> Void) {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var query = ""
        for (index, animeID) in id.enumerated() {
            query += """
          anime\(index): Media(id: \(animeID)) {
            id
            title {
              native
              romaji
              english
            }
            nextAiringEpisode {
              episode
              timeUntilAiring
            }
            episodes
            coverImage {
              large
            }
          }
        """
        }
        query = "{ \(query) }"
        
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
                let media = try JSONDecoder().decode(DynamicSimpleEpisodeDataResponse.self, from: data)
                let origin = Dictionary(uniqueKeysWithValues: media.data.map({
                    ($0.value.id, $0.value)
                }))
                let response = id.compactMap({origin[$0]})
                completion(response)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func fetchAnimeTimeLineInfoByID(id: Int, completion: @escaping (AnimeTimeLineInfo?) -> Void) {
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
      native
      romaji
      english
    }
    nextAiringEpisode {
      episode
      timeUntilAiring
    }
    episodes
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
                let media = try JSONDecoder().decode(AnimeTimeLineInfo.self, from: data)
                completion(media)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    func loadEssentialData(completion: @escaping (EssentialDataCollection.EssentialData) -> Void) {
        isFetchingData = true
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
  GenreCollection
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
                let media = try JSONDecoder().decode(EssentialDataCollection.self, from: data)
                completion(media.data)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
            
        }
        
        // Execute URLSession task
        task.resume()
    }
}

extension AnimeDataFetcher: GetAnimeCharacterDataDelegate {
    func getAnimeCharacterData(id: Int, page: Int) {
        fetchCharacterDetailByCharacterID(id: id, page: page)
    }
}

extension AnimeDataFetcher: FetchAnimeVoiceActorData {
    func fetchAnimeVoiceActorData(id: Int, page: Int) {
        fetchVoiceActorDataByID(id: id, page: page)
    }
}

extension AnimeDataFetcher: FetchMoreVoiceActorData {
    func passMoreVoiceActorData(voiceActorData: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia) {
        passMoreVoiceActorData?.updateVoiceActorData(voiceActorData: voiceActorData)
    }
    
    func fetchMoreVoiceActorData(id: Int, page: Int) {
        fetchMoreVoiceActorDataByID(id: id, page: page)
    }
    
    
}

extension AnimeDataFetcher: FetchAnimeDetailDataByID {
    func passAnimeID(animeID: Int) {
        fetchAnimeByID(id: animeID)
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



