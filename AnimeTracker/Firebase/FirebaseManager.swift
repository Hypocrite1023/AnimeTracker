//
//  FirebaseStoreFunc.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

//users (集合)
// └── user_uid (文檔)
//      └── watched_animes (子集合)
//           ├── anime_id_1 (文檔)
//           │   ├── isFavourite: true
//           │   ├── notify: false
//           |   |-- status: "RELEASING"
//           ├── anime_id_2 (文檔)
//           │   ├── isFavourite: false
//           │   ├── notify: true
//           |   |-- status: "FINISHED"

 /*
 目前需要儲存的資訊
 isFavorite -> Bool
 isNotify -> Bool
 status -> String -> 透過 AnimeInfo.AnimeStatus 轉成enum
 */

struct AnimeInfo {
    enum AnimeStatus: String {
        case finished = "FINISHED"
        case releasing = "RELEASING"
        case notYetReleased = "NOT_YET_RELEASED"
        case cancelled = "CANCELLED"
        case hiatus = "HIATUS"
    }
}

struct FavoriteAndNotify: Codable {
    var isFavorite: Bool
    var isNotify: Bool
}

protocol FirebaseDataProvider {
    func signIn(withEmail: String, password: String) -> AnyPublisher<Void, Error>
//    func register(withEmail: String, password: String, username: String) -> AnyPublisher<Void, Error>
//    func resetPassword(withEmail: String) -> AnyPublisher<Void, Error>
    func loadUserFavorite(perFetch: Int) -> AnyPublisher<[Response.FirebaseAnimeRecord], Error>
    func resetFavoritePagination()
    
    func updateAnimeRecord(userUID: String, animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.FirebaseAnimeRecord, Error>
    
    func getCurrentUserUID() -> String?
}

extension FirebaseDataProvider {
    func loadUserFavorite() -> AnyPublisher<[Response.FirebaseAnimeRecord], Error> {
        loadUserFavorite(perFetch: 50)
    }
}

struct FirebaseError {
    enum Reason: Error {
        case documentNotExist
        case cannotGetUserUID
        case dbError
        case other
    }
}

class FirebaseManager: FirebaseDataProvider {
    
    static let shared = FirebaseManager()
    
    private init() {}
    
    enum FireStoreKeyString {
        static let USER_COLLECTION = "users"
        static let WATCHED_ANIME = "watched_animes"
        static let IS_FAVORITE = "isFavorite"
        static let IS_NOTIFY = "isNotify"
        static let STATUS = "status"
    }
    
    var userFavoriteLastFetchDocument: DocumentSnapshot?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    func loadUserFavoriteAndReleasing(userUID: String, perFetch: Int, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        let userRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME)
        userRef.whereField(FireStoreKeyString.IS_FAVORITE, isEqualTo: true).whereField(FireStoreKeyString.STATUS, isEqualTo: "RELEASING").limit(to: perFetch).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(snapshot?.documents, nil)
            }
        }
    }
    
    
    
    func isAuthenticatedAndEmailVerified() -> Bool {
        guard let currentUser = Auth.auth().currentUser else {
            return false
        }
        return currentUser.isEmailVerified
    }
}


// MARK: - Login, Register, Password and User information related
extension FirebaseManager {
    func signIn(withEmail: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Auth.auth().signIn(withEmail: withEmail, password: password) { _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                    UserCache.shared.userUID = self.getCurrentUserUID()
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        UserCache.shared.userUID = nil
    }
    
    func register(withEmail: String, password: String, username: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Auth.auth().createUser(withEmail: withEmail, password: password) { _, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    if let createProfileChangeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                        createProfileChangeRequest.displayName = username
                        createProfileChangeRequest.commitChanges { error in
                            if let _ = error {
                                promise(.failure(RegisterError.createUsernameFail))
                            }
                        }
                    }
                    
                    Auth.auth().currentUser?.sendEmailVerification { error in
                        if let _ = error {
                            promise(.failure(RegisterError.sendVerifyEmailFail))
                        }
                    }
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func resetPassword(withEmail: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Auth.auth().sendPasswordReset(withEmail: withEmail) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getCurrentUserUID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}

// MARK: - Anime Database manipulate related
extension FirebaseManager {
    
    func isUserDocumentExist(userUID: String) -> AnyPublisher<Bool, Never> {
        let userRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID)
        return Future<Bool, Never> { promise in
            userRef.getDocument { document, error in
                if let _ = error {
                    promise(.success(false))
                } else if let _ = document {
                    promise(.success(true))
                } else {
                    promise(.success(false))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func isAnimeExist(userUID: String, animeID: Int) -> AnyPublisher<Bool, Never> {
        return Future<Bool, Never> { promise in
            self.isUserDocumentExist(userUID: userUID)
                .sink { _ in
                    
                } receiveValue: { isDocumentExist in
                    if isDocumentExist {
                        let animeRef = self.db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME).document("\(animeID)")
                        animeRef.getDocument { document, error in
                            if let _ = error {
                                promise(.success(false))
                            } else {
                                promise(.success(document?.exists ?? false))
                            }
                        }
                    } else {
                        promise(.success(false))
                    }
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func addAnimeRecord(userUID: String, animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Void, Error> {
        let animeRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME).document("\(animeID)")
        let data: [String: Any] = [FireStoreKeyString.IS_FAVORITE: isFavorite, FireStoreKeyString.IS_NOTIFY: isNotify, FireStoreKeyString.STATUS: status]
        
        return Future<Void, Error> { promise in
            self.isUserDocumentExist(userUID: userUID)
                .sink { _ in
                    
                } receiveValue: { isDocumentExist in
                    if isDocumentExist {
                        animeRef.setData(data) { error in
                            if let error = error {
                                promise(.failure(error))
                            }
                            promise(.success(()))
                        }
                    } else {
                        promise(.failure(FirebaseError.Reason.documentNotExist))
                    }
                }
                .store(in: &self.cancellables)
            
        }
        .eraseToAnyPublisher()
    }

    func updateAnimeRecord(userUID: String, animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) -> AnyPublisher<Response.FirebaseAnimeRecord, Error> {
        let animeRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME).document("\(animeID)")
        var data: [String: Any] = [:]
        data[FireStoreKeyString.IS_FAVORITE] = isFavorite
        data[FireStoreKeyString.IS_NOTIFY] = isNotify
        data[FireStoreKeyString.STATUS] = status
        
        return Future<Response.FirebaseAnimeRecord, Error> { promise in
            animeRef.updateData(data) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(.init(id: animeID, isFavorite: isFavorite, isNotify: isNotify)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getAnimeRecord(userUID: String, animeID: Int) -> AnyPublisher<(Bool?, Bool?, String?), Error> {
        let animeRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME).document("\(animeID)")
        return Future<(Bool?, Bool?, String?), Error> { promise in
            self.isAnimeExist(userUID: userUID, animeID: animeID)
                .sink { _ in 
                    // Handle completion if needed, but for now, we only care about the value
                } receiveValue: { isExist in
                    if isExist {
                        animeRef.getDocument { document, error in
                            if let error = error {
                                promise(.failure(error))
                            } else if let document = document, document.exists {
                                let data = document.data()
                                let favorite = data?[FireStoreKeyString.IS_FAVORITE] as? Bool
                                let notify = data?[FireStoreKeyString.IS_NOTIFY] as? Bool
                                let status = data?[FireStoreKeyString.STATUS] as? String
                                promise(.success((favorite, notify, status)))
                            } else {
                                promise(.success((nil, nil, nil)))
                            }
                        }
                    } else {
                        promise(.success((false, false, nil)))
                    }
                }
                .store(in: &self.cancellables)
            
        }
        .eraseToAnyPublisher()
    }
    
    func loadUserNotificationAnime(userUID: String) -> AnyPublisher<[Int], Never> {
        let userRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME)
        return Future<[Int], Never> { promise in
            userRef.whereField(FireStoreKeyString.IS_NOTIFY, isEqualTo: true).whereField(FireStoreKeyString.STATUS, isEqualTo: AnimeInfo.AnimeStatus.releasing.rawValue).getDocuments { snapshot, error in
                if let _ = error {
                    promise(.success([]))
                } else {
                    promise(.success(snapshot?.documents.compactMap { Int($0.documentID) } ?? []))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateAnimeStatus(userUID: String, animeID: Int, status: AnimeInfo.AnimeStatus) -> AnyPublisher<Void, Never> {
        let userRef = db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME).document("\(animeID)")
        return Future<Void, Never> { promise in
            userRef.updateData([
                "status": "FINISHED"
            ]) { error in
                if let _ = error {
                    print("Error updating document")
                } else {
                    print("Document successfully updated")
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Load Favorite Data
extension FirebaseManager {
    
    func resetFavoritePagination() {
        self.userFavoriteLastFetchDocument = nil
    }
    
    func loadUserFavorite(perFetch: Int = 50) -> AnyPublisher<[Response.FirebaseAnimeRecord], Error> {
        
        return Future<[Response.FirebaseAnimeRecord], Error> { [weak self] promise in
            guard let self = self else { return }
            guard let userUID = self.getCurrentUserUID() else {
                promise(.failure(FirebaseError.Reason.cannotGetUserUID))
                return
            }
            
            let userRef = self.db.collection(FireStoreKeyString.USER_COLLECTION).document(userUID).collection(FireStoreKeyString.WATCHED_ANIME)
            
            var query = userRef
                .whereField(FireStoreKeyString.IS_FAVORITE, isEqualTo: true)
                .order(by: FieldPath.documentID())
                .limit(to: perFetch)
            
            if let lastDoc = self.userFavoriteLastFetchDocument {
                query = query.start(afterDocument: lastDoc)
            }
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let snapshot = snapshot {
                    
                    if let lastVisible = snapshot.documents.last {
                        self.userFavoriteLastFetchDocument = lastVisible
                    }
                    
                    let result = snapshot.documents.compactMap { document -> Response.FirebaseAnimeRecord? in
                        let animeInfo = document.data()
                        guard let animeId = Int(document.documentID),
                              let isFavorite = animeInfo[FirebaseManager.FireStoreKeyString.IS_FAVORITE] as? Bool,
                              let isNotify = animeInfo[FirebaseManager.FireStoreKeyString.IS_NOTIFY] as? Bool else {
                            return nil
                        }
                        return Response.FirebaseAnimeRecord(id: animeId, isFavorite: isFavorite, isNotify: isNotify)
                    }
                    promise(.success(result))
                } else {
                    promise(.success([]))
                }
                print("fetch user favorite")
            }
        }
        .eraseToAnyPublisher()
    }
}
