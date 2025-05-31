//
//  AnimeNotification.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/9.
//

import Foundation
import UserNotifications
import Combine

struct EpisodeAndNotificationID {
    let episode: Int
    let notificationID: String
}

class AnimeNotification {
    static let shared = AnimeNotification()
    private init() {}
    
    private var cancellables: Set<AnyCancellable> = []
    
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
        
        print(UserDefaults.standard.dictionary(forKey: "\(animeID)"))
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
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func checkNotification() -> AnyPublisher<(String, [Int: String]), Never> { // 需要回傳 status 已經不是 RELEASING 的動畫 id
        guard let userUID = FirebaseManager.shared.getCurrentUserUID() else {
            return Just(("", [:])).eraseToAnyPublisher()
        }
        return FirebaseManager.shared.loadUserNotificationAnime(userUID: userUID)
            .flatMap { animeIDs -> AnyPublisher<SimpleEpisodeData, Never> in
                animeIDs.publisher
                    .flatMap(maxPublishers: .max(5)) { animeID in
                        AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: animeID)
                            .catch { _ in Empty<SimpleEpisodeData, Never>(completeImmediately: true) }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .collect()
            .map { episodesData in
                var needUpdateAnimeIDs: [Int: String] = [:]
                episodesData.forEach {
                    if $0.data.Media.status != AnimeInfo.AnimeStatus.releasing.rawValue {
                        needUpdateAnimeIDs[$0.data.Media.id] = $0.data.Media.status
                    }
                    if let nextAiringEpisode = $0.data.Media.nextAiringEpisode, let episodes = $0.data.Media.episodes {
                        AnimeNotification.shared.setupAllEpisodeNotification(animeID: $0.data.Media.id, animeTitle: $0.data.Media.title.native, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                    }
                }
                
                return (userUID, needUpdateAnimeIDs)
            }
            .eraseToAnyPublisher()
    }
}
