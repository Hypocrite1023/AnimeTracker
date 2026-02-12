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
    
//    let serialQueue = DispatchQueue(label: "episodeDatasQueue")
    var episodeDatas = [Response.SimpleEpisodeData.DataResponse.SimpleMedia]()
    var animeTimeLineData = [AnimeTimeLineData]()

//    func appendToArray(_ newElements: [SimpleEpisodeData.DataResponse.SimpleMedia]) {
//        serialQueue.async {
//            self.episodeDatas += newElements
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userUID = Auth.auth().currentUser?.uid {
//            loadFavoriteAndReleasingEpisodeData(userUID) {
//                print("completion")
//                if !self.episodeDatas.isEmpty {
//                    for episodeData in self.episodeDatas {
//                        print(episodeData)
//                        
//                        if let nextAiringEpisode = episodeData.nextAiringEpisode?.episode, let totalEpisode = episodeData.episodes, let nextAiringTime = episodeData.nextAiringEpisode?.timeUntilAiring {
//                            for (index, episode) in (nextAiringEpisode...totalEpisode).enumerated() {
//                                print(index)
//                                self.animeTimeLineData.append(AnimeTimeLineData(animeTitle: "\(episodeData.title.native) Ep.\(episode)", animeCoverImage: episodeData.coverImage.large, airingLeft: TimeInterval(nextAiringTime + (604800 * index))))
//                            }
//                        }
//                    }
//                    self.animeTimeLineData.sort { lhs, rhs in
//                        lhs.airingLeft < rhs.airingLeft
//                    }
//                    print(self.animeTimeLineData)
//                    DispatchQueue.main.async {
//                        print("reloadData")
//                        self.animeTimeLineTableView.reloadData()
//                    }
//                }
//                
//                
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animeTimeLineTableView.dataSource = self
        animeTimeLineTableView.delegate = self
//        animeTimeLineTableView.register(AnimeTimeLineTableViewCell.self, forCellReuseIdentifier: "AnimeTimeLineTableViewCell")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        
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
