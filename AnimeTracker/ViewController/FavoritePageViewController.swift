//
//  FavouritePageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct FavoriteAnime: Hashable {
    static func == (lhs: FavoriteAnime, rhs: FavoriteAnime) -> Bool {
        return lhs.animeID == rhs.animeID && lhs.isFavorite == rhs.isFavorite && lhs.isNotify == rhs.isNotify
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(animeID)
        hasher.combine(isFavorite)
        hasher.combine(isNotify)
    }
    
    let animeID: Int
    let isFavorite: Bool
    let isNotify: Bool
    let status: String
    var animeData: SimpleAnimeData.DataResponse.SimpleMedia?
}

enum StatusSection: CaseIterable {
    case releasing
    case finished
    
    var sectionText: String {
        switch(self) {
        case .releasing: return "releasing".uppercased()
        case .finished: return "finished".uppercased()
        }
    }
}

class FavoritePageViewController: UIViewController {
    @IBOutlet weak var favoriteTableView: UITableView!
    
    var favoriteAnimeList: [FavoriteAnime] = []
//    var tmpFavoriteAnimeList: [FavoriteAnime] = []
    var tableViewData: [SimpleAnimeData.DataResponse.SimpleMedia] = []
//    var tmpTableViewData: [SimpleAnimeData.DataResponse.SimpleMedia] = []
    var isEnableLoadMoreData: Bool = false
    
    var tableViewDataSource: UITableViewDiffableDataSource<StatusSection, FavoriteAnime>?
    var tableViewSnapShot = NSDiffableDataSourceSnapshot<StatusSection, FavoriteAnime>()
    var isEnableFetchData: Bool = false
    var isTableDataInitial = false
    
    var lastTimeFetchData = Date.now
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("favorite page view did load")

        // Do any additional setup after loading the view.
        configDataSource()
//        applyInitialSnapShot()
        favoriteTableView.delegate = self
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("favorite page appear")
        self.isEnableFetchData = true
        navigationController?.navigationBar.isHidden = false
        applyInitialSnapShot()
//        if isTableDataInitial {
//            print("favorite page appear and refresh")
//            updateSnapShot()
//        }
//        favoriteAnimeList.removeAll()
    }
    
    func configDataSource() {
        tableViewDataSource = UITableViewDiffableDataSource(tableView: favoriteTableView, cellProvider: { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteAnimeTableViewCell", for: indexPath) as! FavoriteTableViewCell
            cell.animeCoverImageView.loadImage(from: itemIdentifier.animeData?.coverImage.large)
            cell.animeID = itemIdentifier.animeID
            cell.animeTitleLabel.text = itemIdentifier.animeData?.title.native
            cell.configNotify = self
            cell.favoriteAndNotifyConfig = self
            cell.configBtnColor(isFavorite: itemIdentifier.isFavorite, isNotify: itemIdentifier.isNotify, status: itemIdentifier.status)
            print(itemIdentifier.animeData?.title.native, itemIdentifier.isNotify)
            return cell
        })
    }
    
    fileprivate func loadUserFavoriteAnimeList(perFetch: Int, completion: @escaping ([FavoriteAnime]?) -> Void) {
//        print(FirebaseStoreFunc.shared.userFavoriteLastFetchDocument)
        isEnableFetchData = false
        if let userUID = Auth.auth().currentUser?.uid {
            FirebaseStoreFunc.shared.loadUserFavorite(userUID: userUID, perFetch: perFetch) { snapshot, error in
                var tmpFavoriteAnimeList: [FavoriteAnime] = []
                if let error = error {
                    print(error.localizedDescription)
                } else if let documents = snapshot {
                    for document in documents {
                        let data = document.data()
                        let animeID = document.documentID
//                        print(animeID, "animeID")
                        let isFavorite = data?["isFavorite"] as? Bool
                        let isNotify = data?["isNotify"] as? Bool
                        let status = data?["status"] as? String
                        tmpFavoriteAnimeList.append(FavoriteAnime(animeID: Int(animeID) ?? 0, isFavorite: isFavorite ?? false, isNotify: isNotify ?? false, status: status ?? "", animeData: nil))
                    }
                    let animeIdList = tmpFavoriteAnimeList.map({$0.animeID})
                    self.favoriteAnimeList += tmpFavoriteAnimeList
                    print("animeIdList", animeIdList)
                    if !animeIdList.isEmpty {
                        AnimeDataFetcher.shared.fetchAnimeSimpleDataByIDs(id: animeIdList) { simpleAnimeData in
                            
                            for (index, data) in simpleAnimeData.enumerated() {
                                tmpFavoriteAnimeList[index].animeData = data
                            }
                            completion(tmpFavoriteAnimeList)
                        }
                    }
                }
            }
        }
    }
    
    func applyInitialSnapShot() {
        tableViewSnapShot = NSDiffableDataSourceSnapshot<StatusSection, FavoriteAnime>()
        tableViewSnapShot.appendSections([.releasing, .finished])
        
        loadUserFavoriteAnimeList(perFetch: 20) { favoriteAnime in
            if let favoriteAnime = favoriteAnime {
                if !favoriteAnime.isEmpty {
                    for anime in favoriteAnime {
                        if anime.status == "RELEASING" {
                            self.tableViewSnapShot.appendItems([anime], toSection: .releasing)
                        } else if anime.status == "FINISHED" {
                            self.tableViewSnapShot.appendItems([anime], toSection: .finished)
                        }
                    }
                    self.tableViewDataSource?.apply(self.tableViewSnapShot, animatingDifferences: true)
                    print("apply data source")
                }
                self.isEnableFetchData = true
            }
        }
        self.isTableDataInitial = true
    }
    
    func updateSnapShot() {
//        var tableViewSnapShot = NSDiffableDataSourceSnapshot<StatusSection, FavoriteAnime>()
//        tableViewSnapShot.appendSections([.releasing])
        
        loadUserFavoriteAnimeList(perFetch: 20) { favoriteAnime in
            if let favoriteAnime = favoriteAnime {
                if favoriteAnime != [] {
                    for anime in favoriteAnime {
                        if anime.status == "RELEASING" {
                            self.tableViewSnapShot.appendItems([anime], toSection: .releasing)
                        } else if anime.status == "FINISHED" {
                            self.tableViewSnapShot.appendItems([anime], toSection: .finished)
                        }
                    }
                    self.tableViewDataSource?.apply(self.tableViewSnapShot, animatingDifferences: true)
                }
            }
        }
        self.isEnableFetchData = true
    }
}

extension FavoritePageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if Date.now.timeIntervalSince(lastTimeFetchData) < 2 {
            return
        }
        
        if scrollView == favoriteTableView {
//            if (scrollView.contentOffset.y + scrollView.frame.height) > scrollView.contentSize.height + 60 && isEnableFetchData && isTableDataInitial {
//                lastTimeFetchData = Date.now
//                print("scroll to bottom fetch data")
//                updateSnapShot()
//            }
            if scrollView.contentOffset.y < -30 && isEnableFetchData && isTableDataInitial {
                lastTimeFetchData = Date.now
                updateSnapShot()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnimeDataFetcher.shared.fetchAnimeByID(id: tableViewSnapShot.itemIdentifiers[indexPath.row].animeID) { mediaResponse in
            DispatchQueue.main.async {
                let media = mediaResponse.data.media
                let vc = AnimeDetailViewController(mediaID: media.id)
                vc.animeDetailData = media
                vc.navigationItem.title = media.title.native
                vc.animeDetailView = AnimeDetailView(frame: self.view.frame)
                vc.showOverviewView(sender: vc.animeDetailView.animeBannerView.overviewButton)
                vc.fastNavigate = self.tabBarController.self as? any NavigateDelegate
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView(reuseIdentifier: "HeaderView")
        headerView.textLabel?.text = StatusSection.allCases[section].sectionText
        headerView.textLabel?.textColor = .black
        return headerView
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
