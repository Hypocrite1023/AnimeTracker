//
//  AnimeFetchData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/16.
//

import Foundation
import Combine

class AnimeDataFetcher {
    
    static let shared = AnimeDataFetcher()
    
    var queryURL: URL!
    @Published var isFetchingData = false
    
    private init() {
        self.queryURL = URL(string: "https://graphql.anilist.co")!
    }
}

// MARK: - Anime Relate
extension AnimeDataFetcher {
    // MARK: - anime
    func fetchAnimeByID(id: Int) -> AnyPublisher<Response.AnimeDetail, Error> {
        return performGraphQLRequest(operation: .fetchAnimeDetail(id: id))
    }
    
    func fetchRankingDataByMediaId(id: Int) -> AnyPublisher<Response.MediaRanking.MediaData.Media, Error> {
        return performGraphQLRequest(operation: .fetchRanking(mediaId: id))
            .map { (response: Response.MediaRanking) in
                response.data.media
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAnimeSimpleDataByID(id: Int) -> AnyPublisher<Response.AnimeEssentialData, Error> {
        return performGraphQLRequest(operation: .fetchAnimeSimpleData(id: id))
            .map { (response: Response.SimpleMediaResponse) in
                response.data.Media
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAnimeEpisodeDataByID(id: Int) -> AnyPublisher<Response.SimpleEpisodeData, Error> {
        return performGraphQLRequest(operation: .fetchAnimeEpisodeData(id: id))
    }
    
    func fetchAnimeSimpleDataByIDs(id: [Int]) -> AnyPublisher<[Response.AnimeEssentialData], Error> {
        return performGraphQLRequest(operation: .fetchAnimeSimpleDataByIDs(ids: id))
            .map { (response: Response.DynamicSimpleAnimeDataResponse) in
                response.data.map { $0.value }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAnimeEpisodeDataByIDs(ids: [Int]) -> AnyPublisher<[Response.SimpleEpisodeData.DataResponse.SimpleMedia?], Error> {
        return performGraphQLRequest(operation: .fetchAnimeEpisodeDataByIDs(ids: ids))
            .map { (response: Response.DynamicSimpleEpisodeDataResponse) in
                Dictionary(uniqueKeysWithValues: response.data.map { ($0.value.id, $0.value) })
            }
            .compactMap { dict in
                return ids.compactMap { dict[$0] }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAnimeTimeLineInfoByID(id: Int) -> AnyPublisher<Response.AnimeTimeLineInfo?, Error> {
        return performGraphQLRequest(operation: .fetchAnimeTimeLineInfoByID(id: id))
    }
    
    func fetchAnimeListBySeason(year: Int, season: String, page: Int) -> AnyPublisher<Response.AnimeSearchResult<Response.AnimeTimelineData>, Error> {
        return performGraphQLRequest(operation: .fetchAnimeListBySeason(year: year, season: season, page: page))
    }
    
    // MARK: - 啟動 App 要 load 的資料
    func loadAnimeSearchingEssentialData() -> AnyPublisher<Response.EssentialDataCollection.EssentialData, Error> {
        return performGraphQLRequest(operation: .loadAnimeSearchingEssentialData)
            .map { (response: Response.EssentialDataCollection) in
                response.data
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - anime searching
    func searchAnime(title: String, genres: [String], format: [String], sort: String, airingStatus: [String], streamingOn: [String], country: String, sourceMaterial: [String], doujin: Bool, year: Int?, season: String, page: Int) -> AnyPublisher<Response.AnimeSearchingResult, Error> {
        return performGraphQLRequest(operation: .searchAnime(title: title, genres: genres, format: format, sort: sort, airingStatus: airingStatus, streamingOn: streamingOn, country: country, sourceMaterial: sourceMaterial, doujin: doujin, year: year, season: season, page: page))
    }
    
    // MARK: - character
    func fetchCharacterPreviewByMediaId(id: Int, page: Int) -> AnyPublisher<Response.MediaCharacterPreview.MediaData.Media, Error> {
        return performGraphQLRequest(operation: .fetchCharacterPreview(mediaId: id, page: page))
            .map { (response: Response.MediaCharacterPreview) in
                response.data.media
            }
            .eraseToAnyPublisher()
    }
    
    func fetchCharacterDetailByCharacterID(id: Int, page: Int = 1) -> AnyPublisher<Response.CharacterDetail, Error> {
        return performGraphQLRequest(operation: .fetchCharacterDetail(characterId: id, page: page))
    }
    
    // MARK: - voice actor
    func fetchVoiceActorDataByID(id: Int, page: Int = 1) -> AnyPublisher<Response.VoiceActorDataResponse.DataClass.StaffData, Error> {
        return performGraphQLRequest(operation: .fetchVoiceActorData(staffId: id, page: page))
            .map { (response: Response.VoiceActorDataResponse) in
                response.data.Staff
            }
            .eraseToAnyPublisher()
    }
    
    func fetchMoreVoiceActorDataByID(id: Int, page: Int) -> AnyPublisher<Response.VoiceActorDataResponse.DataClass.StaffData.CharacterMedia?, Error> {
        return performGraphQLRequest(operation: .fetchMoreVoiceActorData(staffId: id, page: page))
            .map { (response: Response.VoiceActorData) in
                response.data.Staff.characterMedia
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - staff
    func fetchStaffPreviewByMediaId(id: Int, page: Int) -> AnyPublisher<Response.MediaStaffPreview, Error> {
        return performGraphQLRequest(operation: .fetchStaffPreview(mediaId: id, page: page))
    }
    
    func fetchStaffDetailByID(id: Int) -> AnyPublisher<Response.StaffDetailData.StaffData.Staff, Error> {
        return performGraphQLRequest(operation: .fetchStaffDetail(staffId: id))
            .map { (response: Response.StaffDetailData) in
                response.data.staff
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - thread
    func fetchThreadDataByMediaId(id: Int, page: Int) -> AnyPublisher<Response.ThreadResponse, Error> {
        return performGraphQLRequest(operation: .fetchThreadDataByMediaId(id: id, page: page))
    }
}

// MARK: - Trending
extension AnimeDataFetcher {
    func fetchAnimeByTrending(page: Int) -> AnyPublisher<Response.AnimeTrending, Error> {
        return performGraphQLRequest(operation: .fetchTrendingAnime(page: page))
            .map { (response: Response.AnimeTrending) in
                response
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Category
extension AnimeDataFetcher {
    func fetchAnimeByCategory(genere: [String], sortBy: String, page: Int) -> AnyPublisher<Response.AnimeCategoryResult, Error> {
        return performGraphQLRequest(operation: .fetchAnimeByCategory(genres: genere, sortBy: sortBy, page: page))
    }
}

// MARK: - Helper
private extension AnimeDataFetcher {
    func performGraphQLRequest<T: Decodable>(operation: AnimeRequestGraphQL) -> AnyPublisher<T, Error> {
        var urlRequest = URLRequest(url: queryURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = ["query": operation.query]
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        self.isFetchingData = true
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .handleEvents(receiveCompletion: { [weak self] _ in
                DispatchQueue.main.async { self?.isFetchingData = false }
            }, receiveCancel: { [weak self] in
                DispatchQueue.main.async { self?.isFetchingData = false }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

extension AnimeDataFetcher: FetchAnimeVoiceActorData {
    func fetchAnimeVoiceActorData(id: Int, page: Int) {
        _ = fetchVoiceActorDataByID(id: id, page: page)
    }
}

extension AnimeDataFetcher: FetchMoreVoiceActorData {
    func passMoreVoiceActorData(voiceActorData: Response.VoiceActorDataResponse.DataClass.StaffData.CharacterMedia) {
//        passMoreVoiceActorData?.updateVoiceActorData(voiceActorData: voiceActorData)
    }
    
    func fetchMoreVoiceActorData(id: Int, page: Int) {
        _ = fetchMoreVoiceActorDataByID(id: id, page: page)
    }
}
