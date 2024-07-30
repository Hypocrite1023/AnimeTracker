//
//  AnimeDetailDataDelegate.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/20.
//

import Foundation

protocol AnimeDetailDataDelegate: AnyObject {
    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media)
    func animeDetailCharacterDataDelegate(characterData: MediaCharacterPreview)
    func animeDetailStaffDataDelegate(staffData: MediaStaffPreview)
    func animeDetailRankingDataDelegate(rankingData: MediaRanking.MediaData.Media)
    func animeDetailThreadDataDelegate(threadData: ThreadResponse.PageData)
}
