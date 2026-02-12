//
//  AnimeVoiceActorPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/22.
//

import Foundation
import Combine

class AnimeVoiceActorPageViewModel {
    @Published var voiceActorData: Response.VoiceActorDataResponse.DataClass.StaffData?
    @Published var voiceActorDataEachYear: [Int: [Response.VoiceActorDataResponse.DataClass.StaffData.CharacterMedia.Edge]] = [:]
    private var cancellables: Set<AnyCancellable> = []
    var lastTimeFetch: Date?
    var yearSet: Set<Int> = []
    
    init(voiceActorID: Int) {
        lastTimeFetch = .now
        AnimeDataFetcher.shared.fetchVoiceActorDataByID(id: voiceActorID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { voiceActorData in
                AnimeDataFetcher.shared.isFetchingData = false
                self.voiceActorData = voiceActorData
                guard let edges = voiceActorData.characterMedia?.edges else { return }
                var tmpVoiceActorDataEachYear: [Int: [Response.VoiceActorDataResponse.DataClass.StaffData.CharacterMedia.Edge]] = [:]
                for (_, data) in edges.enumerated() {
                    if let year = data.node.startDate.year {
                        if !self.yearSet.contains(year) {
                            tmpVoiceActorDataEachYear[year] = []
                            tmpVoiceActorDataEachYear[year]?.append(data)
                            self.yearSet.insert(year)
                        } else {
                            tmpVoiceActorDataEachYear[year]?.append(data)
                        }
                    }
                }
                self.voiceActorDataEachYear = tmpVoiceActorDataEachYear
                print("voiceActorDataEachYear", self.voiceActorDataEachYear.keys)
            }
            .store(in: &cancellables)
    }
    
    func fetchMoreVoiceActorData() {
        if let id = voiceActorData?.id, let page = voiceActorData?.characterMedia?.pageInfo.currentPage {
            AnimeDataFetcher.shared.fetchMoreVoiceActorDataByID(id: id, page: page + 1)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    
                } receiveValue: { voiceActorData in
                    AnimeDataFetcher.shared.isFetchingData = false
                    guard let edges = voiceActorData?.edges else { return }
                    var tmpVoiceActorDataEachYear: [Int: [Response.VoiceActorDataResponse.DataClass.StaffData.CharacterMedia.Edge]] = [:]
                    for (_, data) in edges.enumerated() {
                        if let year = data.node.startDate.year {
                            if !self.yearSet.contains(year) {
                                tmpVoiceActorDataEachYear[year] = []
                                tmpVoiceActorDataEachYear[year]?.append(data)
                                self.yearSet.insert(year)
                            } else {
                                tmpVoiceActorDataEachYear[year]?.append(data)
                            }
                        }
                    }
                    self.voiceActorDataEachYear.merge(tmpVoiceActorDataEachYear) { old, new in
                        old + new
                    }
                    guard let voiceActorData = voiceActorData else { return }
                    self.voiceActorData?.characterMedia?.pageInfo = voiceActorData.pageInfo
                }
                .store(in: &cancellables)
        }
    }
    
    func bindLoadMoreVoiceActorTriggerToViewModel(trigger: PassthroughSubject<Void, Never>) {
        trigger
            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: false)
            .sink { _ in
                self.fetchMoreVoiceActorData()
            }
            .store(in: &cancellables)
    }
}
