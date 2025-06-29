//
//  AnimeFetchData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/16.
//

import Foundation
import Combine

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
            let status: String
            
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
    let data: [String: Response.AnimeEssentialData]
}

struct DynamicSimpleEpisodeDataResponse: Codable {
    let data: [String: SimpleEpisodeData.DataResponse.SimpleMedia]
}

struct EssentialDataCollection: Codable {
    let data: EssentialData
    
    struct EssentialData: Codable {
        let genreCollection: [String]
        let externalLinkSourceCollection: [ExternalLinkSourceCollection]
        
        struct ExternalLinkSourceCollection: Codable {
            let site: String
        }
    }
}

struct StaffDetailData: Codable {
    let data: StaffData
    
    struct StaffData: Codable {
        let staff: Staff
        
        struct Staff: Codable {
            let id: Int
            let name: Name
            let primaryOccupations: [String]
            let image: StaffImage
            let description: String
            let staffMedia: StaffMedia
            
            struct StaffImage: Codable {
                let large: String
            }
            struct StaffMedia: Codable {
                let edges: [Edge]
                struct Edge: Codable {
                    let staffRole: String
                    let node: Node
                    struct Node: Codable {
                        let id: Int
                        let coverImage: CoverImage
                        let title: Title
                        let type: String
                        
                        struct Title: Codable {
                            let native: String
                        }
                        struct CoverImage: Codable {
                            let large: String
                        }
                    }
                }
            }
            struct Name: Codable {
                let native: String?
                let userPreferred: String
            }
        }
    }
}

class AnimeDataFetcher {
    
    static let shared = AnimeDataFetcher()
    
    var queryURL: URL!
    @Published var isFetchingData = false
    
    private init() {
        self.queryURL = URL(string: "https://graphql.anilist.co")!
    }
    
    // TODO: - 這些 function 要改成回傳 Publisher
    func fetchAnimeSimpleDataByIDs(id: [Int], completion: @escaping ([Response.AnimeEssentialData?]) -> Void) {
        isFetchingData = true
//        print(id)
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
                let orderedMediaArray: [Response.AnimeEssentialData] = id.compactMap { mediaDictionary[$0] }
                
                completion(orderedMediaArray)
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
    
}

// MARK: - Anime Relate
extension AnimeDataFetcher {
    // MARK: - anime
    func fetchAnimeByID(id: Int) -> AnyPublisher<Response.AnimeDetail, Error> {
        isFetchingData = true
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
        }
        // Create URLSession task
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                self.isFetchingData = false
                return data
            }
            .decode(type: Response.AnimeDetail.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchRankingDataByMediaId(id: Int) -> AnyPublisher<MediaRanking.MediaData.Media, Error> {
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
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: MediaRanking.self, decoder: JSONDecoder())
            .map {
                $0.data.media
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAnimeSimpleDataByID(id: Int) -> AnyPublisher<Response.AnimeEssentialData, Error> {
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
        }
        // Create URLSession task
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map {
                print($0.data)
                return $0
            }
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                self.isFetchingData = false

                // 解析 JSON
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let mediaDict = (json?["data"] as? [String: Any])?["Media"] else {
                    throw URLError(.cannotParseResponse)
                }

                let mediaData = try JSONSerialization.data(withJSONObject: mediaDict)
                return mediaData
            }
            .decode(type: Response.AnimeEssentialData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchAnimeEpisodeDataByID(id: Int) -> AnyPublisher<SimpleEpisodeData, Error> {
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
    status
  }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: SimpleEpisodeData.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - 啟動 App 要 load 的資料
    func loadAnimeSearchingEssentialData() -> AnyPublisher<EssentialDataCollection.EssentialData, Error> {
        isFetchingData = true
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
  genreCollection: GenreCollection
  externalLinkSourceCollection: ExternalLinkSourceCollection(type: STREAMING, mediaType: ANIME) {
    site
  }
}
"""
        
        let graphQLData = ["query": query]
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
        }
        // Create URLSession task
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: EssentialDataCollection.self, decoder: JSONDecoder())
            .map {
                self.isFetchingData = false
                return $0.data
            }
            .eraseToAnyPublisher()
    }
    // MARK: - anime searching
    func searchAnime(title: String, genres: [String], format: [String], sort: String, airingStatus: [String], streamingOn: [String], country: String, sourceMaterial: [String], doujin: Bool, year: Int?, season: String, page: Int) -> AnyPublisher<AnimeSearchingResult, Error> {
        isFetchingData = true
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(genres.isEmpty)
        let query = """
query {
    Page(page: \(page), perPage: 50) {
        pageInfo {
            hasNextPage
            currentPage
        }
        media(isAdult: false, type: ANIME\(title == "" ? "": ", search: \"\(title)\"")\(genres.isEmpty ? "" : ", genre_in: \(genres)")\(format.isEmpty ? "" : ", format_in: [\(format.joined(separator: ", "))]"), sort: \(sort == "" ? "POPULARITY_DESC" : sort)\(airingStatus.isEmpty ? "" : ", status_in: [\(airingStatus.joined(separator: ", "))]")\(streamingOn.isEmpty ? "" : ", licensedBy_in: \(streamingOn)")\(country == "" ? "" : ", countryOfOrigin: \(country)")\(sourceMaterial.isEmpty ? "" : ", source_in: [\(sourceMaterial.joined(separator: ", "))]"), isLicensed: \(!doujin)\(year == nil ? "" : ", seasonYear: \(year!)")\(season == "" ? "" : ", season: \(season.uppercased())")) {
            id
            title {
                romaji
                english
                native
            }
            coverImage {
                extraLarge
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
        }
        // Create URLSession task
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: AnimeSearchingResult.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    // MARK: - character
    func fetchCharacterPreviewByMediaId(id: Int, page: Int) -> AnyPublisher<MediaCharacterPreview.MediaData.Media, Error> {
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
        }
        // Create URLSession task
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
            
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: MediaCharacterPreview.self, decoder: JSONDecoder())
            .map {
                $0.data.media
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCharacterDetailByCharacterID(id: Int, page: Int = 1) -> AnyPublisher<CharacterDetail, Error> {
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
        }
        // Create URLSession task
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CharacterDetail.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    
    // MARK: - voice actor
    func fetchVoiceActorDataByID(id: Int, page: Int = 1) -> AnyPublisher<VoiceActorDataResponse.DataClass.StaffData, Error> {
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
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
            
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: VoiceActorDataResponse.self, decoder: JSONDecoder())
            .map {
                $0.data.Staff
            }
            .eraseToAnyPublisher()
    }
    
    func fetchMoreVoiceActorDataByID(id: Int, page: Int) -> AnyPublisher<VoiceActorDataResponse.DataClass.StaffData.CharacterMedia?, Error> {
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
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: VoiceActorData.self, decoder: JSONDecoder())
            .map {
                $0.data.Staff.characterMedia
            }
            .eraseToAnyPublisher()
    }
    // MARK: - staff
    func fetchStaffPreviewByMediaId(id: Int, page: Int) -> AnyPublisher<MediaStaffPreview, Error> {
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
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: MediaStaffPreview.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func fetchStaffDetailByID(id: Int) -> AnyPublisher<StaffDetailData.StaffData.Staff, Error> {
        isFetchingData = true
        print(id)
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let query = """
query {
    staff: Staff(id: \(id)) {
    id
    name {
      native
      userPreferred
    }
    primaryOccupations
    image {
      large
    }
    description(asHtml: false)
    staffMedia {
      edges {
        staffRole
        node {
          id
          coverImage {
            large
          }
          title {
            native
          }
          type
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
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response")
                    throw URLError(.badServerResponse)
                }
//                print(String(data: data, encoding: .utf8))
                return data
            }
            .decode(type: StaffDetailData.self, decoder: JSONDecoder())
            .map {
                $0.data.staff
            }
            .eraseToAnyPublisher()
    }
    
    // TODO: thread 的資料目前沒有用到
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
//                self.animeDetailDataDelegate?.animeDetailThreadDataDelegate(threadData: media.data)
                self.isFetchingData = false
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        // Execute URLSession task
        task.resume()
    }
    
    
}

// MARK: - Trending
extension AnimeDataFetcher {
    func fetchAnimeByTrending(page: Int) -> AnyPublisher<Response.AnimeTrending, Error> {
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
                    large
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
        }
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map({$0.data})
            .map {
                return $0
            }
            .decode(type: Response.AnimeTrending.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: - Category {
struct AnimeCategoryResult: Codable {
    var data: [String: Media]
    struct Media: Codable {
        let media: [Anime]
    }
    
    struct Anime: Codable {
        let id: Int
        let title: Title
        let coverImage: CoverImage
        
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

extension AnimeDataFetcher {
    
    
    
    func genreateGenreQuery(genere: [String], sortBy: String, page: Int) -> String {
        var queryString = ""
        
        for (_, value) in genere.enumerated() {
            let genreKey = value
                .lowercased()
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "-", with: "_")
            let genreTemplate = """
                          \(genreKey): Page(perPage: 20, page: \(page)) {
                                media(genre: "\(value.lowercased())", type: ANIME, sort: \(sortBy)) {
                                    id
                                    title {
                                      native
                                    }
                                    coverImage {
                                      large
                                    }
                                }
                            }
            """
            queryString += "\(genreTemplate)\n"
        }
        return queryString
    }
    
    func fetchAnimeByCategory(genere: [String], sortBy: String, page: Int) -> AnyPublisher<AnimeCategoryResult, Error> {
//        isFetchingData = true
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "post"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        
        let query = """
            query {
              \(genreateGenreQuery(genere: genere, sortBy: sortBy, page: page))
            }
            """
        
        let graphQLData = ["query": query]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: graphQLData, options: [])
        } catch {
            print("Error serializing JSON: \(error.localizedDescription)")
        }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map({$0.data})
            .map {
                return $0
            }
            .decode(type: AnimeCategoryResult.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        
    }
}

extension AnimeDataFetcher: FetchAnimeVoiceActorData {
    func fetchAnimeVoiceActorData(id: Int, page: Int) {
        fetchVoiceActorDataByID(id: id, page: page)
    }
}

extension AnimeDataFetcher: FetchMoreVoiceActorData {
    func passMoreVoiceActorData(voiceActorData: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia) {
//        passMoreVoiceActorData?.updateVoiceActorData(voiceActorData: voiceActorData)
    }
    
    func fetchMoreVoiceActorData(id: Int, page: Int) {
        fetchMoreVoiceActorDataByID(id: id, page: page)
    }
    
    
}

//extension AnimeDataFetcher: FetchAnimeDetailDataByID {
//    func passAnimeID(animeID: Int) {
//        fetchAnimeByID(id: animeID)
//    }
//    
//    
//}
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
