//
//  AnimeDetailPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/17.
//

import Foundation
import Combine

class AnimeDetailPageViewModel {
    
    // MARK: - input
    let shouldLoadMoreStaff: PassthroughSubject<Void, Never> = .init()
    let shouldShowOverview: PassthroughSubject<Void, Never> = .init()
    let shouldShowWatch: PassthroughSubject<Void, Never> = .init()
    let shouldShowCharacters: PassthroughSubject<Void, Never> = .init()
    let shouldLoadMoreCharacters: PassthroughSubject<Void, Never> = .init()
    let shouldShowStats: PassthroughSubject<Void, Never> = .init()
    let shouldShowSocial: PassthroughSubject<Void, Never> = .init()
    let shouldShowStaff: PassthroughSubject<Void, Never> = .init()
    let shouldShowAlert: PassthroughSubject<String, Never> = .init()
    // MARK: - output
    var newCharacterData: AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> = .empty
    var newStaffData: AnyPublisher<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .empty
    var showOverview: AnyPublisher<MediaResponse.MediaData.Media?, Never> = .empty
    var showWatch: AnyPublisher<[MediaResponse.MediaData.Media.StreamingEpisodes], Never> = .empty
    var showCharacters: AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> = .empty
    var shouldUpdateCharacters: AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> = .empty
    var showStats: AnyPublisher<(MediaRanking.MediaData.Media?, MediaResponse.MediaData.Media.Stats?), Never> = .empty
    var showAlert: AnyPublisher<String, Never> = .empty
    // MARK: - data property
    let animeID: Int
    @Published var animeDetailData: MediaResponse.MediaData.Media?
    @Published var animeCharacterData: [MediaResponse.MediaData.Media.CharacterPreview.Edges] = []
    @Published var newAnimeCharacterData: [MediaResponse.MediaData.Media.CharacterPreview.Edges] = []
    @Published var animeRankingData: MediaRanking.MediaData.Media?
    @Published var animeStaffData: MediaResponse.MediaData.Media.StaffPreview?
    let newAnimeStaffDataPassThrough: PassthroughSubject<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .init()
    var lastFetchDataTime: Date?
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(animeID: Int) {
        self.animeID = animeID
        lastFetchDataTime = .now
        AnimeDataFetcher.shared.fetchAnimeByID(id: animeID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            } receiveValue: { response in
                self.animeDetailData = response.data.media
                self.animeCharacterData = response.data.media.characterPreview.edges
                self.animeStaffData = response.data.media.staffPreview
            }
            .store(in: &cancellable)
        
        setupPublisher()
    }
    
    private func setupSubscriber() {
        
    }
    
    private func setupPublisher() {
        showOverview = shouldShowOverview
            .flatMap {
                return self.$animeDetailData
                    .compactMap { $0 }
                    .prefix(1)
            }
            .eraseToAnyPublisher()
        
        showWatch = shouldShowWatch
            .flatMap {
                return self.$animeDetailData
                    .compactMap { $0 }
                    .prefix(1)
            }
            .compactMap {
                $0.streamingEpisodes
            }
            .eraseToAnyPublisher()
        
        showCharacters = shouldShowCharacters
            .flatMap {
                return self.$animeCharacterData
                    .compactMap { $0 }
                    .prefix(1)
            }
            .eraseToAnyPublisher()
        
        shouldUpdateCharacters = shouldLoadMoreCharacters
            .throttle(for: 2, scheduler: RunLoop.main, latest: false)
            .filter { self.animeDetailData?.characterPreview.pageInfo.hasNextPage == true }
            .compactMap {
                guard let animeID = self.animeDetailData?.id, let currentPage = self.animeDetailData?.characterPreview.pageInfo.currentPage else {
                    return nil
                }
                return (animeID, currentPage)
            }
            .flatMap { (id, page) in
                AnimeDataFetcher.shared.fetchCharacterPreviewByMediaId(id: id, page: page + 1)
                    .handleEvents(
                        receiveCompletion: { _ in
                            AnimeDataFetcher.shared.isFetchingData = false
                        },
                        receiveCancel: {
                            AnimeDataFetcher.shared.isFetchingData = false
                        }
                    )
                    .map {
                        self.animeDetailData?.characterPreview.pageInfo = $0.characterPreview.pageInfo
                        return $0.characterPreview.edges
                    }
                    .catch { error -> AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> in
                        self.shouldShowAlert.send(error.localizedDescription)
                        return Just([]).eraseToAnyPublisher()
                    }
            }
            .eraseToAnyPublisher()
        
        showStats = shouldShowStats
            .flatMap { _ -> AnyPublisher<MediaRanking.MediaData.Media, Never> in
                guard let animeRankingData = self.animeRankingData else {
                    return AnimeDataFetcher.shared.fetchRankingDataByMediaId(id: self.animeID)
                        .prefix(1)
                        .assertNoFailure()
                        .eraseToAnyPublisher()
                }
                return Just(animeRankingData).eraseToAnyPublisher()
            }
            .map { rankingData in
                return (rankingData, self.animeDetailData?.stats)
            }
            .handleEvents(receiveOutput: { (rankingData, stats) in
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeRankingData = rankingData
            })
            .eraseToAnyPublisher()
        
        showAlert = shouldShowAlert.eraseToAnyPublisher()
    }
    
    func loadAnimeRankingData() {
        if let animeID = animeDetailData?.id {
            AnimeDataFetcher.shared.fetchRankingDataByMediaId(id: animeID)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    
                } receiveValue: { rankingData in
                    AnimeDataFetcher.shared.isFetchingData = false
                    self.animeRankingData = rankingData
                }
                .store(in: &cancellable)
        }
        
    }
}
