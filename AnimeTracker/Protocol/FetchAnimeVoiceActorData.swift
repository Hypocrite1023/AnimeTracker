//
//  AnimeStaffDataDelegate.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import Foundation

protocol FetchAnimeVoiceActorData: AnyObject {
    func fetchAnimeVoiceActorData(id: Int, page: Int)
}

protocol AnimeVoiceActorDataDelegate: AnyObject {
    func animeVoiceActorDataDelegate(voiceActorData: VoiceActorDataResponse.DataClass.StaffData)
}

protocol FetchMoreVoiceActorData: AnyObject {
    func fetchMoreVoiceActorData(id: Int, page: Int)
    func passMoreVoiceActorData(voiceActorData: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia)
}

protocol ReceiveMoreVoiceActorData: AnyObject {
    func updateVoiceActorData(voiceActorData: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia?)
}
