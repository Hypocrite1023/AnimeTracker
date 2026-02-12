//
//  AnimeDetailDataDelegate.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/20.
//

import Foundation

protocol AnimeDetailDataDelegate: AnyObject {
//    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media)
    func animeDetailCharacterDataDelegate(characterData: Response.MediaCharacterPreview)
    func animeDetailStaffDataDelegate(staffData: Response.MediaStaffPreview)
    func animeDetailRankingDataDelegate(rankingData: Response.MediaRanking.MediaData.Media)
    func animeDetailThreadDataDelegate(threadData: Response.ThreadResponse.PageData)
}

protocol AnimeOverViewDataDelegate: AnyObject {
    func animeDetailDataDelegate(media: Response.AnimeDetail.MediaData.Media)
}

protocol FetchAnimeDetailDataByID: AnyObject {
    func passAnimeID(animeID: Int)
}
