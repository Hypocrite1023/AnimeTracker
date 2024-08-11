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
    var tableViewData: [SimpleAnimeData.DataResponse.SimpleMedia] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        favoriteTableView.dataSource = self
        favoriteTableView.delegate = self
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
                    let animeIdList = self.favoriteAnimeList.map({$0.animeID})
                    print("animeIdList", animeIdList)
                    AnimeDataFetcher.shared.fetchAnimeSimpleDataByIDs(id: animeIdList) { simpleAnimeData in
                        self.tableViewData = simpleAnimeData.compactMap({$0})
//                        print(simpleAnimeData)
                        DispatchQueue.main.async {
                            self.favoriteTableView.reloadData()
                            print("reload data")
                        }
                    }
                    
//                    print(self.favoriteAnimeList)
                }
            }
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("favorite page appear")
//        favoriteAnimeList.removeAll()
        
        
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
        tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteAnimeTableViewCell") as! FavoriteTableViewCell
        cell.animeID = favoriteAnimeList[indexPath.row].animeID
        cell.animeCoverImageView.loadImage(from: tableViewData[indexPath.row].coverImage.large)
        cell.animeTitleLabel.text = tableViewData[indexPath.row].title.native
        cell.configNotify = self
        cell.favoriteAndNotifyConfig = self
        cell.configBtnColor(isFavorite: favoriteAnimeList[indexPath.row].isFavorite, isNotify: favoriteAnimeList[indexPath.row].isNotify, status: favoriteAnimeList[indexPath.row].status)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnimeDataFetcher.shared.fetchAnimeByID(id: favoriteAnimeList[indexPath.row].animeID)
        tableView.deselectRow(at: indexPath, animated: true)
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
