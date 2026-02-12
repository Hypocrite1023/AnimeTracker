//
//  AnimeCharacterPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/21.
//

import Foundation
import Combine

class AnimeCharacterPageViewModel {
    var voiceActorLanguageTypeSet: Set<String> = Set<String>()
    @Published var characterData: Response.CharacterDetail? {
        didSet {
            let _ = characterData?.data.Character.media?.edges.map { characterDetail in
                if let voiceActorRoles = characterDetail.voiceActorRoles {
                    for (_, voiceActor) in voiceActorRoles.enumerated() {
                        if !voiceActorLanguageTypeSet.contains(voiceActor.voiceActor.language) {
                            voiceActorLanguageTypeSet.insert(voiceActor.voiceActor.language)
                        }
                    }
                }
            }
            if voiceActorLanguageTypeSet.contains("Japanese") {
                self.filterCharacterDataBy(language: "Japanese")
            } else {
                if let lan = voiceActorLanguageTypeSet.first {
                    self.filterCharacterDataBy(language: lan)
                }
            }
            
        }
    }
    @Published var characterDataFiltered: Response.CharacterDetail?
    private var cancellable: Set<AnyCancellable> = []
    
    init(characterID: Int) {
        AnimeDataFetcher.shared.fetchCharacterDetailByCharacterID(id: characterID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { characterDetails in
                AnimeDataFetcher.shared.isFetchingData = false
//                print(characterDetails)
                self.characterData = characterDetails
            }
            .store(in: &cancellable)

    }
    
    func filterCharacterDataBy(language lan: String) {
        var tmpCharacterDataFiltered: Response.CharacterDetail? = characterData ?? nil
        var filteredCharacterData: [Response.CharacterDetail.CharacterData.CharacterDataInData.Media.Edge] = []
        if let characterData = characterData?.data.Character.media?.edges {
            for (index, cData) in characterData.enumerated() {
                if let voiceActorRoles = cData.voiceActorRoles {
                    if voiceActorRoles.count != 0 {
                        var tmpFilteredData: [Response.CharacterDetail.CharacterData.CharacterDataInData.Media.Edge.VoiceActorRoles] = []
                        for (_, voiceActorData) in voiceActorRoles.enumerated() {
                            if voiceActorData.voiceActor.language == lan {
                                tmpFilteredData.append(voiceActorData)
                            }
                        }
                        if tmpFilteredData.count != 0 {
                            var originData = characterData[index]
                            originData.voiceActorRoles = tmpFilteredData
                            filteredCharacterData.append(originData)
                        }
                    } else {
                        let originData = characterData[index]
                        filteredCharacterData.append(originData)
                    }
                    
                }
                
            }
        }
        tmpCharacterDataFiltered?.data.Character.media?.edges = filteredCharacterData
        characterDataFiltered = tmpCharacterDataFiltered
    }
}
