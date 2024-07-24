//
//  AnimeStreamingDetailDelegate.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/22.
//

import Foundation

protocol AnimeStreamingDetailDelegate: AnyObject {
    func passStreamingDetail() -> [MediaResponse.MediaData.Media.StreamingEpisodes]
    func passStreamingDetailCount() -> Int
}
