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
    @Published var animeRankingData: MediaRanking?
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
}
