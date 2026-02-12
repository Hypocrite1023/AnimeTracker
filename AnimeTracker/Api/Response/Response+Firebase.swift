//
//  Response+Firebase.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation

extension Response {
    struct FirebaseAnimeRecord {
        let id: Int
        let isFavorite: Bool
        let isNotify: Bool
    }
}
