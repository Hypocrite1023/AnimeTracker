//
//  LocalRecordManager.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import Foundation
import Combine
import CoreData

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
    func loadUserFavorite(perFetch: Int, userStatus: UserAnimeStatus?, sortBy: FavoriteSortOption) -> AnyPublisher<[Response.LocalAnimeRecord], Error>
    func resetFavoritePagination()
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String, userStatus: UserAnimeStatus?) -> AnyPublisher<Response.LocalAnimeRecord, Error>
}

extension UserDataProvider {
    func loadUserFavorite(perFetch: Int) -> AnyPublisher<[Response.LocalAnimeRecord], Error> {
        return loadUserFavorite(perFetch: perFetch, userStatus: nil, sortBy: .addedAt)
    }
    
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.LocalAnimeRecord, Error> {
        return updateAnimeRecord(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status, userStatus: nil)
    }
}

class LocalRecordManager: UserDataProvider {
    static let shared = LocalRecordManager()
    
    private let persistentContainer: NSPersistentContainer
    private var lastFetchIndex = 0
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "AnimeTracker")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        viewContext.automaticallyMergesChangesFromParent = true
        
        // Trigger migration if old JSON exists
        migrateOldJSONIfNeeded()
    }
    
    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("favorites.json")
    }
    
    private func migrateOldJSONIfNeeded() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let oldRecords = try decoder.decode([LocalAnimeRecord].self, from: data)
            
            for old in oldRecords {
                let record = fetchOrCreateRecord(animeID: old.id)
                record.isFavorite = old.isFavorite
                record.isNotify = old.isNotify
                record.status = old.status
                record.userStatus = UserAnimeStatus.planToWatch.rawValue
                record.addedAt = Date()
                record.updatedAt = Date()
            }
            
            try viewContext.save()
            try FileManager.default.removeItem(at: fileURL)
            print("🎉 Successfully migrated favorites.json to Core Data!")
        } catch {
            print("❌ Error migrating old JSON: \(error)")
        }
    }
    
    // MARK: - Core Data Helpers
    
    private func fetchOrCreateRecord(animeID: Int) -> CDAnimeRecord {
        let request: NSFetchRequest<CDAnimeRecord> = CDAnimeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", animeID)
        
        if let results = try? viewContext.fetch(request), let existing = results.first {
            return existing
        }
        
        let newRecord = CDAnimeRecord(context: viewContext)
        newRecord.id = Int64(animeID)
        newRecord.addedAt = Date()
        return newRecord
    }
    
    @discardableResult
    private func updateRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String, userStatus: UserAnimeStatus?) -> CDAnimeRecord {
        let record = fetchOrCreateRecord(animeID: animeID)
        record.isFavorite = isFavorite
        record.isNotify = isNotify
        record.status = status
        
        if let userStatus = userStatus {
            record.userStatus = userStatus.rawValue
        } else if record.userStatus == nil {
            record.userStatus = UserAnimeStatus.planToWatch.rawValue
        }
        
        record.updatedAt = Date()
        
        if !isFavorite && !isNotify {
            viewContext.delete(record)
        }
        
        try? viewContext.save()
        return record
    }
    
    // MARK: - Database APIs
    
    func getAnimeRecord(animeID: Int) -> AnyPublisher<Response.LocalAnimeRecord?, Error> {
        let request: NSFetchRequest<CDAnimeRecord> = CDAnimeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", animeID)
        
        do {
            let results = try viewContext.fetch(request)
            if let record = results.first {
                let userStatus = UserAnimeStatus(rawValue: record.userStatus ?? "") ?? .planToWatch
                let mapped = Response.LocalAnimeRecord(
                    id: Int(record.id),
                    isFavorite: record.isFavorite,
                    isNotify: record.isNotify,
                    userStatus: userStatus,
                    addedAt: record.addedAt ?? Date(),
                    updatedAt: record.updatedAt ?? Date()
                )
                return Just(mapped).setFailureType(to: Error.self).eraseToAnyPublisher()
            } else {
                return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func addAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Void, Error> {
        updateRecord(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status, userStatus: nil)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateAnimeRecord(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String, userStatus: UserAnimeStatus?) -> AnyPublisher<Response.LocalAnimeRecord, Error> {
        let record = updateRecord(animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status, userStatus: userStatus)
        let mapped = Response.LocalAnimeRecord(
            id: Int(record.id),
            isFavorite: record.isFavorite,
            isNotify: record.isNotify,
            userStatus: UserAnimeStatus(rawValue: record.userStatus ?? "") ?? .planToWatch,
            addedAt: record.addedAt ?? Date(),
            updatedAt: record.updatedAt ?? Date()
        )
        return Just(mapped).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func loadUserNotificationAnime() -> AnyPublisher<[Int], Never> {
        let request: NSFetchRequest<CDAnimeRecord> = CDAnimeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "isNotify == YES AND status == %@", AnimeInfo.AnimeStatus.releasing.rawValue)
        
        if let results = try? viewContext.fetch(request) {
            let ids = results.map { Int($0.id) }
            return Just(ids).eraseToAnyPublisher()
        }
        return Just([]).eraseToAnyPublisher()
    }
    
    func updateAnimeStatus(animeID: Int, status: AnimeInfo.AnimeStatus) -> AnyPublisher<Void, Never> {
        let request: NSFetchRequest<CDAnimeRecord> = CDAnimeRecord.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", animeID)
        
        if let results = try? viewContext.fetch(request), let record = results.first {
            record.status = status.rawValue
            record.updatedAt = Date()
            try? viewContext.save()
        }
        return Just(()).eraseToAnyPublisher()
    }
    
    // MARK: - Pagination APIs
    
    func resetFavoritePagination() {
        lastFetchIndex = 0
    }
    
    func loadUserFavorite(perFetch: Int = 10, userStatus: UserAnimeStatus?, sortBy: FavoriteSortOption) -> AnyPublisher<[Response.LocalAnimeRecord], Error> {
        let request: NSFetchRequest<CDAnimeRecord> = CDAnimeRecord.fetchRequest()
        
        var predicates = [NSPredicate(format: "isFavorite == YES")]
        if let userStatus = userStatus {
            predicates.append(NSPredicate(format: "userStatus == %@", userStatus.rawValue))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        var sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        if sortBy == .addedAt {
            sortDescriptor = NSSortDescriptor(key: "addedAt", ascending: false)
        } else if sortBy == .updatedAt {
            sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        }
        request.sortDescriptors = [sortDescriptor]
        
        let isInMemorySort = (sortBy == .score || sortBy == .alphabetical)
        if !isInMemorySort {
            request.fetchLimit = perFetch
            request.fetchOffset = lastFetchIndex
        }
        
        do {
            let results = try viewContext.fetch(request)
            if !isInMemorySort {
                lastFetchIndex += results.count
            }
            
            let mapped = results.map { record in
                Response.LocalAnimeRecord(
                    id: Int(record.id),
                    isFavorite: record.isFavorite,
                    isNotify: record.isNotify,
                    userStatus: UserAnimeStatus(rawValue: record.userStatus ?? "") ?? .planToWatch,
                    addedAt: record.addedAt ?? Date(),
                    updatedAt: record.updatedAt ?? Date()
                )
            }
            return Just(mapped).setFailureType(to: Error.self).eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
