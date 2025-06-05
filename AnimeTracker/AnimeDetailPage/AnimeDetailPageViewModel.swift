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
    let shouldShowOverview: PassthroughSubject<Void, Never> = .init()
    let shouldShowWatch: PassthroughSubject<Void, Never> = .init()
    let shouldShowCharacters: PassthroughSubject<Void, Never> = .init()
    let shouldLoadMoreCharacters: PassthroughSubject<Void, Never> = .init()
    let shouldShowStats: PassthroughSubject<Void, Never> = .init()
    let shouldShowSocial: PassthroughSubject<Void, Never> = .init()
    let shouldShowStaff: PassthroughSubject<Void, Never> = .init()
    let shouldLoadMoreStaffs: PassthroughSubject<Void, Never> = .init()
    let shouldShowAlert: PassthroughSubject<AlertType, Never> = .init()
    let configFavorite: PassthroughSubject<Void, Never> = .init()
    let configNotification: PassthroughSubject<Void, Never> = .init()
    let shouldShowLoginPage: PassthroughSubject<Void, Never> = .init()
    // MARK: - output
    private(set) var newCharacterData: AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> = .empty
    private(set) var newStaffData: AnyPublisher<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .empty
    private(set) var showOverview: AnyPublisher<MediaResponse.MediaData.Media?, Never> = .empty
    private(set) var showWatch: AnyPublisher<[MediaResponse.MediaData.Media.StreamingEpisodes], Never> = .empty
    private(set) var showCharacters: AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> = .empty
    private(set) var shouldUpdateCharacters: AnyPublisher<[MediaResponse.MediaData.Media.CharacterPreview.Edges], Never> = .empty
    private(set) var showStats: AnyPublisher<(MediaRanking.MediaData.Media?, MediaResponse.MediaData.Media.Stats?), Never> = .empty
    private(set) var showStaffs: AnyPublisher<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .empty
    private(set) var shouldUpdateStaffs: AnyPublisher<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .empty
    private(set) var showAlert: AnyPublisher<AlertType, Never> = .empty
    private(set) var configFavoritePublisher: AnyPublisher<Bool, Never> = .empty
    private(set) var configNotificationPublisher: AnyPublisher<Bool, Never> = .empty
    private(set) var showLoginPage: AnyPublisher<Void, Never> = .empty
    // MARK: - data property
    let animeID: Int
    let userUID: String?
    @Published var isFavorite: Bool = false
    @Published var isNotify: Bool = false
    var isFirebaseDataInitFinished: Bool = false
    @Published var animeDetailData: MediaResponse.MediaData.Media?
    @Published var animeCharacterData: [MediaResponse.MediaData.Media.CharacterPreview.Edges] = []
    @Published var newAnimeCharacterData: [MediaResponse.MediaData.Media.CharacterPreview.Edges] = []
    @Published var animeRankingData: MediaRanking.MediaData.Media?
    @Published var animeStaffData: [MediaResponse.MediaData.Media.StaffPreview.Edges] = []
    let newAnimeStaffDataPassThrough: PassthroughSubject<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .init()
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(animeID: Int) {
        self.animeID = animeID
        let userUidOptional: String? = FirebaseManager.shared.getCurrentUserUID()
        userUID = userUidOptional
        
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
                self.animeStaffData = response.data.media.staffPreview.edges
            }
            .store(in: &cancellable)
        
        if let userUID = userUidOptional {
            FirebaseManager.shared.getAnimeRecord(userUID: userUID, animeID: self.animeID)
                .sink(receiveCompletion: { completion in
                    switch completion {
                        
                    case .finished:
                        break
                    case .failure(let error):
                        self.shouldShowAlert.send(.apiError(message: error.localizedDescription))
                    }
                }, receiveValue: { (favorite, notify, _) in
                    self.isFavorite = favorite ?? false
                    self.isNotify = notify ?? false
                    self.isFirebaseDataInitFinished = true
                    print("isFavorite: \(self.isFavorite); isNotify: \(self.isNotify)")
                })
                .store(in: &cancellable)
            
            
        }
        setupSubscriber()
        setupPublisher()
        
    }
    
    private func setupSubscriber() {
        $isFavorite
            .combineLatest($isNotify)
            .dropFirst()
            .filter { _ in self.isFirebaseDataInitFinished && FirebaseManager.shared.isAuthenticatedAndEmailVerified() }
            .flatMap { isFavorite, isNotify -> AnyPublisher<Void, Error> in
                print("isFavorite: \(isFavorite); isNotify: \(isNotify)")
                let animeStatus = self.animeDetailData?.status ?? ""
                return FirebaseManager.shared.addAnimeRecord(userUID: self.userUID!, animeID: self.animeID, isFavorite: isFavorite, isNotify: isNotify, status: animeStatus)
            }
            .catch{ error in
                self.shouldShowAlert.send(.apiError(message: error.localizedDescription))
                return Empty<Void, Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            .sink { _ in
                
            }
            .store(in: &cancellable)
        
        configFavorite
            .sink { [weak self] _ in
                print("---")
                if FirebaseManager.shared.isAuthenticatedAndEmailVerified() {
                    self?.isFavorite.toggle()
                } else {
                    self?.shouldShowAlert.send(.needLogin)
                }
            }
            .store(in: &cancellable)
        
        configNotification
            .sink { [weak self] _ in
                print("---")
                if FirebaseManager.shared.isAuthenticatedAndEmailVerified() {
                    self?.isNotify.toggle()
                } else {
                    self?.shouldShowAlert.send(.needLogin)
                }
            }
            .store(in: &cancellable)
        
        $isNotify
            .filter { _ in self.isFirebaseDataInitFinished && FirebaseManager.shared.isAuthenticatedAndEmailVerified() }
            .sink { isNotify in
                if isNotify {
                    guard let animeTitle = self.animeDetailData?.title.native, let nextAiringEpisode = self.animeDetailData?.nextAiringEpisode, let episodes = self.animeDetailData?.episodes else { return }
                    print(animeTitle, nextAiringEpisode)
                    AnimeNotification.shared.setupAllEpisodeNotification(animeID: self.animeID, animeTitle: animeTitle, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                } else {
                    AnimeNotification.shared.removeAllEpisodeNotification(for: self.animeID)
                }
            }
            .store(in: &cancellable)
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
                        self.shouldShowAlert.send(.apiError(message: error.localizedDescription))
                        return Just([]).eraseToAnyPublisher()
                    }
            }
            .eraseToAnyPublisher()
        
        showStats = shouldShowStats
            .flatMap { _ -> AnyPublisher<MediaRanking.MediaData.Media, Never> in
                guard let animeRankingData = self.animeRankingData else {
                    return AnimeDataFetcher.shared.fetchRankingDataByMediaId(id: self.animeID)
                        .prefix(1)
                        .catch({ error in
                            self.shouldShowAlert.send(.apiError(message: error.localizedDescription))
                            return Empty<MediaRanking.MediaData.Media, Never>(completeImmediately: true)
                                .eraseToAnyPublisher()
                        })
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
        
        showStaffs = shouldShowStaff
            .flatMap {
                return self.$animeStaffData
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        shouldUpdateStaffs = shouldLoadMoreStaffs
            .throttle(for: 2, scheduler: RunLoop.main, latest: false)
            .filter { self.animeDetailData?.staffPreview.pageInfo.hasNextPage ?? false }
            .compactMap {
                return self.animeDetailData?.staffPreview.pageInfo.currentPage
            }
            .flatMap { currentPage in
                return AnimeDataFetcher.shared.fetchStaffPreviewByMediaId(id: self.animeID, page: currentPage + 1)
                    .handleEvents(receiveCompletion: { _ in
                        AnimeDataFetcher.shared.isFetchingData = false
                    }, receiveCancel: {
                        AnimeDataFetcher.shared.isFetchingData = false
                    })
                    .map {
                        self.animeDetailData?.staffPreview.pageInfo = $0.data.media.staffPreview.pageInfo
                        self.animeStaffData.append(contentsOf: $0.data.media.staffPreview.edges)
                        return $0.data.media.staffPreview.edges
                    }
                    .catch { error in
                        self.shouldShowAlert.send(.apiError(message: error.localizedDescription))
                        return Empty<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never>(completeImmediately: true).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        showAlert = shouldShowAlert.eraseToAnyPublisher()
        
        configFavoritePublisher = $isFavorite.eraseToAnyPublisher()
        
        configNotificationPublisher = $isNotify.eraseToAnyPublisher()
        
        showLoginPage = shouldShowLoginPage
            .filter({ !FirebaseManager.shared.isAuthenticatedAndEmailVerified() })
            .eraseToAnyPublisher()
    }
}
