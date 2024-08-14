//
//  AnimeNotification.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/9.
//

import Foundation
import UserNotifications
import FirebaseAuth

struct EpisodeAndNotificationID {
    let episode: Int
    let notificationID: String
}

class AnimeNotification {
    static let shared = AnimeNotification()
    private init() {
        
    }
    
    func addNotificationIDToUserDefault(animeID: Int, episode: Int, id: String) {
        if let currentAnimeNotification = UserDefaults.standard.dictionary(forKey: "\(animeID)") {
            var current = currentAnimeNotification
            current["\(episode)"] = id
            UserDefaults.standard.set(current, forKey: "\(animeID)")
        } else {
            UserDefaults.standard.set(["\(episode)": id], forKey: "\(animeID)")
        }
    }
    
    func scheduleLocalNotification(animeID: Int, animeTitle: String, episode: Int, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "New Anime Airing!"
        content.body = "\(animeTitle) Ep.\(episode) is now Airing."
        content.sound = UNNotificationSound.default
        
        // 設定通知時間
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // 建立通知請求
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        addNotificationIDToUserDefault(animeID: animeID, episode: episode, id: uuid)
        
        // 將通知請求加入通知中心
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                print("Notification scheduled.")
            }
        }
    }
    
    func setupAllEpisodeNotification(animeID: Int, animeTitle: String, nextAiringEpsode: Int, nextAiringInterval: TimeInterval, totalEpisode: Int) {
        for (index, episode) in (nextAiringEpsode...totalEpisode).enumerated() {
            scheduleLocalNotification(animeID: animeID, animeTitle: animeTitle, episode: episode, timeInterval: nextAiringInterval + TimeInterval(index * 604800))
        }
        
        print(UserDefaults.standard.dictionary(forKey: animeTitle))
    }
    
    func removeAllEpisodeNotification(for animeID: Int) {
        let notifications = UserDefaults.standard.dictionary(forKey: "\(animeID)")
        if let notifications = notifications as? [String: String] {
            print(notifications)
            notifications.values.forEach { id in
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                print("notification \(id) have been removed")
            }
        }
        UserDefaults.standard.removeObject(forKey: "\(animeID)")
    }
    
    func removeAllNotification() {
        if let userUID = Auth.auth().currentUser?.uid {
            FirebaseStoreFunc.shared.loadUserNotificationAnime(userUID: userUID) { document, error in
                if let document = document {
                    let animeIDs = document.map({$0.documentID})
                    for animeID in animeIDs {
                        self.removeAllEpisodeNotification(for: Int(animeID)!)
                    }
                }
            }
        }
    }
    
    func checkNotification() {
        if let userUID = Auth.auth().currentUser?.uid {
            FirebaseStoreFunc.shared.loadUserNotificationAnime(userUID: userUID) { document, error in
                if let document = document {
                    let animeIDs = document.map({$0.documentID})
                    for animeID in animeIDs {
                        AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: Int(animeID)!) { episodeData in
                            if let nextAiringEpisode = episodeData?.data.Media.nextAiringEpisode, let episodes = episodeData?.data.Media.episodes, let animeTitle = episodeData?.data.Media.title.native {
                                AnimeNotification.shared.setupAllEpisodeNotification(animeID: Int(animeID)!, animeTitle: animeTitle, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                            }
                        }
                    }
                }
            }
        }
    }
}
