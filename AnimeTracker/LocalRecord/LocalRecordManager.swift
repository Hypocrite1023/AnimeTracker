//
//  LocalRecordManager.swift
//  AnimeTracker
//
//  Created by Antigravity on 2026/6/5.
//

import Foundation
import Combine

struct LocalAnimeRecord: Codable {
    let id: Int
    var isFavorite: Bool
    var isNotify: Bool
    var status: String
}

struct AnimeInfo {
    enum AnimeStatus: String {
        case finished = "FINISHED"
        case releasing = "RELEASING"
        case notYetReleased = "NOT_YET_RELEASED"
        case cancelled = "CANCELLED"
        case hiatus = "HIATUS"
    }
}

protocol UserDataProvider {
    func loadUserFavorite(perFetch: Int) -> AnyPublisher<[Response.LocalAnimeRecord], Error>
    func resetFavoritePagination()
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.LocalAnimeRecord, Error>
}

class LocalRecordManager: UserDataProvider {
    static let shared = LocalRecordManager()
    
    private let fileName = "favorites.json"
    private var favoritesMap: [Int: LocalAnimeRecord] = [:]
    private var lastFetchIndex = 0
    
    private init() {
        loadFromDisk()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(fileName)
    }
    
    private func loadFromDisk() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let list = try decoder.decode([LocalAnimeRecord].self, from: data)
            self.favoritesMap = Dictionary(uniqueKeysWithValues: list.map { ($0.id, $0) })
        } catch {
            self.favoritesMap = [:]
        }
    }
    
    private func saveToDisk() {
        do {
            let list = Array(favoritesMap.values)
            let data = try JSONEncoder().encode(list)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save favorites to disk: \(error)")
        }
    }
    
    // MARK: - Database APIs
    
    func getAnimeRecord(animeID: Int) -> AnyPublisher<(Bool?, Bool?, String?), Error> {
        let record = favoritesMap[animeID]
        return Just((record?.isFavorite, record?.isNotify, record?.status))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Void, Error> {
        updateRecord(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.LocalAnimeRecord, Error> {
        updateRecord(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
        return Just(Response.LocalAnimeRecord(id: animeID, isFavorite: isFavorite, isNotify: isNotify))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    private func updateRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) {
        var record = favoritesMap[animeID] ?? LocalAnimeRecord(id: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status)
        record.isFavorite = isFavorite
        record.isNotify = isNotify
        record.status = status
        
        if !isFavorite && !isNotify {
            favoritesMap.removeValue(forKey: animeID)
        } else {
            favoritesMap[animeID] = record
        }
        saveToDisk()
    }
    
    func loadUserNotificationAnime() -> AnyPublisher<[Int], Never> {
        let notifyingIDs = favoritesMap.values
            .filter { $0.isNotify && $0.status == AnimeInfo.AnimeStatus.releasing.rawValue }
            .map { $0.id }
        return Just(notifyingIDs).eraseToAnyPublisher()
    }
    
    func updateAnimeStatus(animeID: Int, status: AnimeInfo.AnimeStatus) -> AnyPublisher<Void, Never> {
        if var record = favoritesMap[animeID] {
            record.status = status.rawValue
            favoritesMap[animeID] = record
            saveToDisk()
        }
        return Just(()).eraseToAnyPublisher()
    }
    
    // MARK: - Pagination APIs
    
    func resetFavoritePagination() {
        lastFetchIndex = 0
    }
    
    func loadUserFavorite(perFetch: Int = 10) -> AnyPublisher<[Response.LocalAnimeRecord], Error> {
        let allFavorites = favoritesMap.values
            .filter { $0.isFavorite }
            .sorted { $0.id < $1.id }
            .map { Response.LocalAnimeRecord(id: $0.id, isFavorite: $0.isFavorite, isNotify: $0.isNotify) }
        
        if lastFetchIndex >= allFavorites.count {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let endIndex = min(lastFetchIndex + perFetch, allFavorites.count)
        let subList = Array(allFavorites[lastFetchIndex..<endIndex])
        lastFetchIndex = endIndex
        
        return Just(subList)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
