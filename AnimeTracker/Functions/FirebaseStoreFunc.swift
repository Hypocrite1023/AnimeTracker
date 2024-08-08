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
//           ├── anime_id_2 (文檔)
//           │   ├── isFavourite: false
//           │   ├── notify: true

struct FavoriteAndNotify: Codable {
    var isFavorite: Bool
    var isNotify: Bool
}

class FirebaseStoreFunc {
    static let shared = FirebaseStoreFunc()
    let db = Firestore.firestore()
    private init() {
        
    }
    func establishUserDocument(userUID: String, completion: @escaping (Bool, Error?) -> Void) {
    }
    
    func isUserDocumentExist(userUID: String, completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection("users").document(userUID)
        
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
        let animeRef = db.collection("users").document(userUID).collection("watched_animes").document("\(animeID)")
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
    
    func addAnimeRecord(userUID: String, animeID: Int, isFavorite: Bool, isNotify: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let animeRef = db.collection("users").document(userUID).collection("watched_animes").document("\(animeID)")
        let data: [String: Bool] = ["isFavorite": isFavorite, "isNotfiy": isNotify]
        animeRef.setData(data) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    func getAnimeRecord(userUID: String, animeID: Int, completion: @escaping (Bool?, Bool?, Error?) -> Void) {
        let animeRef = db.collection("users").document(userUID).collection("watched_animes").document("\(animeID)")
        animeRef.getDocument { document, error in
            if let error = error {
                completion(nil, nil, error)
            } else if let document = document, document.exists {
                let data = document.data()
                let favorite = data?["isFavorite"] as? Bool
                let notify = data?["isNotify"] as? Bool
                completion(favorite, notify, nil)
            } else {
                completion(nil, nil, nil)
            }
        }
    }
}
