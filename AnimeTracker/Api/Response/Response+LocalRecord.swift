//
//  Response+LocalRecord.swift
//  AnimeTracker
//

import Foundation

enum UserAnimeStatus: String, Codable, CaseIterable {
    case planToWatch = "PLAN_TO_WATCH"
    case watching = "WATCHING"
    case completed = "COMPLETED"
    
    var localizedTitle: String {
        switch self {
        case .planToWatch: return "Plan to Watch"
        case .watching: return "Watching"
        case .completed: return "Completed"
        }
    }
}

enum FavoriteSortOption: String, CaseIterable {
    case addedAt = "Date Added"
    case updatedAt = "Recently Updated"
    case score = "Average Score"
    case alphabetical = "Alphabetical (A-Z)"
}

extension Response {
    struct LocalAnimeRecord {
        let id: Int
        let isFavorite: Bool
        let isNotify: Bool
        let userStatus: UserAnimeStatus
        let addedAt: Date
        let updatedAt: Date
    }
}
