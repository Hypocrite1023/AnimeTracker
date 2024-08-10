//
//  FavouritePageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct FavoriteAnime {
    let animeID: Int
    let isFavorite: Bool
    let isNotify: Bool
    let status: String
}

class FavoritePageViewController: UIViewController {
    @IBOutlet weak var favoriteTableView: UITableView!
    
    var favoriteAnimeList: [FavoriteAnime] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        favoriteAnimeList.removeAll()
        if let userUID = Auth.auth().currentUser?.uid {
            FirebaseStoreFunc.shared.loadUserFavorite(userUID: userUID, perFetch: 10) { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                } else if let documents = snapshot {
                    for document in documents {
                        let data = document.data()
                        let animeID = document.documentID
                        let isFavorite = data?["isFavorite"] as? Bool
                        let isNotify = data?["isNotify"] as? Bool
                        let status = data?["status"] as? String
                        self.favoriteAnimeList.append(FavoriteAnime(animeID: Int(animeID) ?? 0, isFavorite: isFavorite ?? false, isNotify: isNotify ?? false, status: status ?? ""))
                    }
                    DispatchQueue.main.async {
                        self.favoriteTableView.reloadData()
                        print("reload data")
                    }
//                    print(self.favoriteAnimeList)
                }
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension FavoritePageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteAnimeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteAnimeTableViewCell") as! FavoriteTableViewCell
        AnimeDataFetcher.shared.fetchAnimeSimpleDataByID(id: favoriteAnimeList[indexPath.row].animeID) { simpleAnimeData in
            if let data = simpleAnimeData?.data.Media {
                cell.animeID = self.favoriteAnimeList[indexPath.row].animeID
                cell.animeCoverImageView.loadImage(from: data.coverImage.large)
                cell.favoriteAndNotifyConfig = self
                cell.configNotify = self
                DispatchQueue.main.async {
                    cell.animeTitleLabel.text = data.title.native
                }
                cell.configBtnColor(isFavorite: self.favoriteAnimeList[indexPath.row].isFavorite, isNotify: self.favoriteAnimeList[indexPath.row].isNotify, status: data.status)
                print(data.title.native, self.favoriteAnimeList[indexPath.row].isFavorite, self.favoriteAnimeList[indexPath.row].isNotify, self.favoriteAnimeList[indexPath.row].status)
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnimeDataFetcher.shared.fetchAnimeByID(id: favoriteAnimeList[indexPath.row].animeID)
    }
}

extension FavoritePageViewController: ConfigFavoriteAndNotifyWithAnimeID {
    func configFavoriteAndNotifyWithAnimeID(animeID: Int, isFavorite: Bool, isNotify: Bool, status: String) {
        if let userUID = Auth.auth().currentUser?.uid {
            FirebaseStoreFunc.shared.addAnimeRecord(userUID: userUID, animeID: animeID, isFavorite: isFavorite, isNotify: isNotify, status: status) { success, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                if success {
                    print("change status success")
                }
            }
        }
    }
    
}

extension FavoritePageViewController: ConfigAnimdNotify {
    func configAnimdNotify(animeID: Int, isNotify: Bool) {
        if isNotify {
            AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: animeID) { episodeData in
                if let nextAiringEpisode = episodeData?.data.Media.nextAiringEpisode, let episodes = episodeData?.data.Media.episodes, let animeTitle = episodeData?.data.Media.title.native {
                    AnimeNotification.shared.setupAllEpisodeNotification(animeID: animeID, animeTitle: animeTitle, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                }
            }
        } else {
            AnimeNotification.shared.removeAllEpisodeNotification(for: animeID)
        }
        
    }
}
