//
//  AnimeDetailPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/17.
//

import Foundation
import Combine

class AnimeDetailPageViewModel {
    @Published var animeDetailData: MediaResponse.MediaData.Media?
    @Published var animeCharacterData: MediaResponse.MediaData.Media.CharacterPreview?
    @Published var newAnimeCharacterData: [MediaResponse.MediaData.Media.CharacterPreview.Edges] = []
    @Published var animeRankingData: MediaRanking.MediaData.Media?
    @Published var animeStaffData: MediaResponse.MediaData.Media.StaffPreview?
    let newAnimeStaffDataPassThrough: PassthroughSubject<[MediaResponse.MediaData.Media.StaffPreview.Edges], Never> = .init()
    var lastFetchDataTime: Date?
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(animeID: Int) {
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
                self.animeCharacterData = response.data.media.characterPreview
                self.animeStaffData = response.data.media.staffPreview
            }
            .store(in: &cancellable)
    }
    
    func loadMoreCharactersData() {
        if let id = animeDetailData?.id, let page = animeCharacterData?.pageInfo.currentPage {
            AnimeDataFetcher.shared.fetchCharacterPreviewByMediaId(id: id, page: page + 1)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                        
                    case .finished:
                        break
                    case .failure(_):
                        break
                    }
                } receiveValue: { mediaCharacterPreview in
                    AnimeDataFetcher.shared.isFetchingData = false
                    self.animeCharacterData?.edges.append(contentsOf: mediaCharacterPreview.characterPreview.edges)
                    self.animeCharacterData?.pageInfo = mediaCharacterPreview.characterPreview.pageInfo
                    self.newAnimeCharacterData = mediaCharacterPreview.characterPreview.edges
                    print(mediaCharacterPreview.characterPreview.pageInfo.hasNextPage)
                }
                .store(in: &cancellable)
        }
        
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
    
    func subscribeLoadMoreStaffDataTrigger(trigger: AnyPublisher<Void, Never>) {
        trigger
            .throttle(for: 2, scheduler: DispatchQueue.main, latest: false)
            .compactMap { [weak self] _ -> (Int, Int)? in
                guard let mediaID = self?.animeDetailData?.id, let page = self?.animeStaffData?.pageInfo.currentPage else { return nil }
                return (mediaID, page + 1)
            }
            .flatMap { (id, page) -> AnyPublisher<MediaStaffPreview, Error> in
                AnimeDataFetcher.shared.fetchStaffPreviewByMediaId(id: id, page: page)
            }
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { mediaStaffPreview in
                AnimeDataFetcher.shared.isFetchingData = false
                self.animeStaffData?.pageInfo = mediaStaffPreview.data.media.staffPreview.pageInfo
                self.newAnimeStaffDataPassThrough.send(mediaStaffPreview.data.media.staffPreview.edges)
            })
            .store(in: &cancellable)
    }
}
