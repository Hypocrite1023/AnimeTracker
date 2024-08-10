//
//  FirebaseStoreFunc.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import Foundation
import FirebaseFirestore

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

struct FavoriteAndNotify: Codable {
    var isFavorite: Bool
    var isNotify: Bool
}

class FirebaseStoreFunc {
    static let shared = FirebaseStoreFunc()
    enum FireStoreKeyString {
        static let USERSCOLLECTION = "users"
        static let WATCHEDANIME = "watched_animes"
        static let FAVORITESTR = "isFavorite"
        static let NOTIFYSTR = "isNotify"
        static let STATUSSTR = "status"
    }
    
    let db = Firestore.firestore()
    private init() {
        
    }
    func establishUserDocument(userUID: String, completion: @escaping (Bool, Error?) -> Void) {
    }
    
    func isUserDocumentExist(userUID: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection(FireStoreKeyString.USERSCOLLECTION).document(userUID)
        
        userRef.getDocument { document, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false, error)
            } else if let document = document, document.exists {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func isAnimeExist(userUID: String, animeID: Int, completion: @escaping (Bool, Error?) -> Void) {
        // first check user document exist
        isUserDocumentExist(userUID: userUID) { exist, error in
            if !exist {
                completion(false, error)
            }
        }
        let animeRef = db.collection(FireStoreKeyString.USERSCOLLECTION).document(userUID).collection(FireStoreKeyString.WATCHEDANIME).document("\(animeID)")
        animeRef.getDocument { document, error in
            if let error = error {
                completion(false, error)
            } else if let document = document, document.exists {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func addAnimeRecord(userUID: String, animeID: Int, isFavorite: Bool, isNotify: Bool, status: String, completion: @escaping (Bool, Error?) -> Void) {
        let animeRef = db.collection(FireStoreKeyString.USERSCOLLECTION).document(userUID).collection(FireStoreKeyString.WATCHEDANIME).document("\(animeID)")
        let data: [String: Any] = [FireStoreKeyString.FAVORITESTR: isFavorite, FireStoreKeyString.NOTIFYSTR: isNotify, FireStoreKeyString.STATUSSTR: status]
        animeRef.setData(data) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func getAnimeRecord(userUID: String, animeID: Int, completion: @escaping (Bool?, Bool?, String?, Error?) -> Void) {
        let animeRef = db.collection(FireStoreKeyString.USERSCOLLECTION).document(userUID).collection(FireStoreKeyString.WATCHEDANIME).document("\(animeID)")
        animeRef.getDocument { document, error in
            if let error = error {
                completion(nil, nil, nil, error)
            } else if let document = document, document.exists {
                let data = document.data()
                let favorite = data?[FireStoreKeyString.FAVORITESTR] as? Bool
                let notify = data?[FireStoreKeyString.NOTIFYSTR] as? Bool
                let status = data?[FireStoreKeyString.STATUSSTR] as? String
                completion(favorite, notify, status, nil)
            } else {
                completion(nil, nil, nil, nil)
            }
        }
    }
    
    func loadUserFavorite(userUID: String, perFetch: Int, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        let userRef = db.collection(FireStoreKeyString.USERSCOLLECTION).document(userUID).collection(FireStoreKeyString.WATCHEDANIME)
        userRef.whereField(FireStoreKeyString.FAVORITESTR, isEqualTo: true).limit(to: 20).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(snapshot?.documents, nil)
            }
        }
    }
    
    func loadUserFavoriteAndReleasing(userUID: String, perFetch: Int, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
        let userRef = db.collection(FireStoreKeyString.USERSCOLLECTION).document(userUID).collection(FireStoreKeyString.WATCHEDANIME)
        userRef.whereField(FireStoreKeyString.FAVORITESTR, isEqualTo: true).whereField(FireStoreKeyString.STATUSSTR, isEqualTo: "RELEASING").limit(to: perFetch).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(snapshot?.documents, nil)
            }
        }
    }
}
