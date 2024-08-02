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
