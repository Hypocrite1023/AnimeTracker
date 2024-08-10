//
//  AnimeTimeLineTableViewViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/10.
//

import UIKit
import FirebaseAuth

struct AnimeTimeLineData {
    let animeTitle: String
    let animeCoverImage: String
    let airingLeft: TimeInterval
}


class AnimeTimeLineTableViewViewController: UIViewController {
    
    // animeTitle, animeCoverImage, timeLeftToAiring, animeID, Ep,
    @IBOutlet weak var animeTimeLineTableView: UITableView!
    
    let serialQueue = DispatchQueue(label: "episodeDatasQueue")
    var episodeDatas = [SimpleEpisodeData]()
    var animeTimeLineData = [AnimeTimeLineData]()

    func appendToArray(_ newElement: SimpleEpisodeData) {
        serialQueue.async {
            self.episodeDatas.append(newElement)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animeTimeLineTableView.dataSource = self
        animeTimeLineTableView.delegate = self
//        animeTimeLineTableView.register(AnimeTimeLineTableViewCell.self, forCellReuseIdentifier: "AnimeTimeLineTableViewCell")
    }
    
    fileprivate func loadFavoriteAndReleasingEpisodeData(_ userUID: String, completion: @escaping () -> Void) {
        self.episodeDatas.removeAll()
        FirebaseStoreFunc.shared.loadUserFavoriteAndReleasing(userUID: userUID, perFetch: 20) { snapshot, error in
            var dataFetched = 0
            if let documents = snapshot {
                for document in documents {
                    let animeID = document.documentID
                    print(animeID)
                    if let animeIDInt = Int(animeID) {
                        AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: animeIDInt) { episodeData in
                            if let episodeData = episodeData {
                                self.appendToArray(episodeData)
                                dataFetched += 1
                                if dataFetched == documents.count {
                                    completion()
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let userUID = Auth.auth().currentUser?.uid {
            loadFavoriteAndReleasingEpisodeData(userUID) {
                for episodeData in self.episodeDatas {
                    if let nextAiringEpisode = episodeData.data.Media.nextAiringEpisode?.episode, let totalEpisode = episodeData.data.Media.episodes, let nextAiringTime = episodeData.data.Media.nextAiringEpisode?.timeUntilAiring {
                        for (index, episode) in (nextAiringEpisode...totalEpisode).enumerated() {
//                            print(episodeData.data.Media.title.native, episode, (index + 1) * nextAiringTime)
                            print(index)
                            self.animeTimeLineData.append(AnimeTimeLineData(animeTitle: "\(episodeData.data.Media.title.native) Ep.\(episode)", animeCoverImage: episodeData.data.Media.coverImage.large, airingLeft: TimeInterval(nextAiringTime + (604800 * index))))
                        }
                    }
                    
                }
                self.animeTimeLineData.sort { lhs, rhs in
                    lhs.airingLeft < rhs.airingLeft
                }
                print(self.animeTimeLineData)
                DispatchQueue.main.async {
                    print("reloadData")
                    self.animeTimeLineTableView.reloadData()
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

extension AnimeTimeLineTableViewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeTimeLineData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeTimeLineTableViewCell") as! AnimeTimeLineTableViewCell
        cell.animeTitleLabel.text = self.animeTimeLineData[indexPath.row].animeTitle
        cell.animeCoverImageView.loadImage(from: self.animeTimeLineData[indexPath.row].animeCoverImage)
        cell.airingLeftTimeLabel.text = AnimeDetailFunc.airingTime(from: self.animeTimeLineData[indexPath.row].airingLeft)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension AnimeTimeLineTableViewViewController: UITableViewDelegate {
    
}
