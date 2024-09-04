//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/18.
//

import UIKit
import Combine
import FirebaseAuth


class TrendingPageViewController: UIViewController {
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
//    var animeFetchManager = AnimeDataFetcher()
    var animeFetchedData: AnimeSearchedOrTrending?
    
    private var cancellables = Set<AnyCancellable>()
    var fetchingDataIndicator = UIActivityIndicatorView(style: .large)
    var selectedAnimeCell: UICollectionViewCell?
    
    var lastFetchData: Date?
    var currentLongPressCellStatus: (isFavorite: Bool?, isNotify: Bool?, status: String?, animeID: Int?)
    var favoriteBtn: UIButton!, notifyBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AnimeDataFetcher.shared.animeOverViewDataDelegate = self
        AnimeDataFetcher.shared.animeDataDelegateManager = self
        AnimeDataFetcher.shared.fetchAnimeByTrending(page: AnimeDataFetcher.shared.trendingNextFetchPage)
        AnimeDataFetcher.shared.isFetchingData = false
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        
        print(UIDevice.current.model, UIDevice.current.batteryLevel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.tabBarController?.selectedIndex = 1
    }
    
    deinit {
        print("TrendingPageViewController deinit")
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
extension TrendingPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeFetchedData?.data.Page.media.count ?? 50
    }
    
    @objc func closeBlurView() {
        if let selectedAnimeCell = selectedAnimeCell {
            removeBlur(cell: selectedAnimeCell)
        }
    }
    
    func setConfigButton(backgroundColor: UIColor, tintColor: UIColor, buttonImage: UIImage?, isTrue: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle("", for: .normal)
        button.backgroundColor = isTrue ? backgroundColor : .secondaryLabel
        button.tintColor = tintColor.withAlphaComponent(isTrue ? 1.0 : 0.5)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        var buttonConf = UIButton.Configuration.plain()
        buttonConf.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        buttonConf.cornerStyle = .medium
        buttonConf.buttonSize = .large
        buttonConf.image = buttonImage
        button.configuration = buttonConf
//        favoriteBtn.contentHorizontalAlignment = .fill
//        favoriteBtn.contentVerticalAlignment = .fill
        return button
    }
    
    @objc func favoriteBtnTap() {
        DispatchQueue.main.async {
            self.currentLongPressCellStatus.0?.toggle()
            if let favorite = self.currentLongPressCellStatus.0 {
                print(self.currentLongPressCellStatus.0)
                self.favoriteBtn.backgroundColor = favorite ? .systemYellow.withAlphaComponent(0.7) : .secondaryLabel
                self.favoriteBtn.tintColor = favorite ? .white.withAlphaComponent(1) : .white.withAlphaComponent(0.5)
            } else {
                self.currentLongPressCellStatus.0 = true
                self.favoriteBtn.backgroundColor = .systemYellow.withAlphaComponent(0.7)
                self.favoriteBtn.tintColor = .white.withAlphaComponent(1)
            }
            if let userUID = Auth.auth().currentUser?.uid, let animeID = self.currentLongPressCellStatus.animeID {
                FirebaseStoreFunc.shared.addAnimeRecord(userUID: userUID, animeID: animeID, isFavorite: self.currentLongPressCellStatus.isFavorite!, isNotify: self.currentLongPressCellStatus.isNotify!, status: self.currentLongPressCellStatus.status ?? "") { isSuccess, error in
                    print("Is success?", isSuccess)
                }
            }
        }
    }
    
    @objc func notifyBtnTap() {
        DispatchQueue.main.async {
            self.currentLongPressCellStatus.1?.toggle()
            if let favorite = self.currentLongPressCellStatus.1 {
                print(self.currentLongPressCellStatus.1)
                self.notifyBtn.backgroundColor = favorite ? .systemBlue.withAlphaComponent(0.7) : .secondaryLabel
                self.notifyBtn.tintColor = favorite ? .white.withAlphaComponent(1) : .white.withAlphaComponent(0.5)
            } else {
                self.currentLongPressCellStatus.1 = true
                self.notifyBtn.backgroundColor = .systemBlue.withAlphaComponent(0.7)
                self.notifyBtn.tintColor = .white.withAlphaComponent(1)
            }
            if let userUID = Auth.auth().currentUser?.uid, let animeID = self.currentLongPressCellStatus.animeID {
                FirebaseStoreFunc.shared.addAnimeRecord(userUID: userUID, animeID: animeID, isFavorite: self.currentLongPressCellStatus.isFavorite!, isNotify: self.currentLongPressCellStatus.isNotify!, status: self.currentLongPressCellStatus.status ?? "") { isSuccess, error in
                    print("Is success?", isSuccess)
                }
            }
            if self.currentLongPressCellStatus.isNotify! {
                AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: self.currentLongPressCellStatus.animeID!) { episodeData in
                    if let nextAiringEpisode = episodeData?.data.Media.nextAiringEpisode, let episodes = episodeData?.data.Media.episodes, let animeTitle = episodeData?.data.Media.title.native {
                        AnimeNotification.shared.setupAllEpisodeNotification(animeID: self.currentLongPressCellStatus.animeID!, animeTitle: animeTitle, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                    }
                }
            } else {
                AnimeNotification.shared.removeAllEpisodeNotification(for: self.currentLongPressCellStatus.animeID!)
            }
        }
    }
    
    func applyBlur(cell: UICollectionViewCell, animeID: Int) {
        if let userUID = Auth.auth().currentUser?.uid {
            var animeStatus: String?
            AnimeDataFetcher.shared.fetchAnimeSimpleDataByID(id: animeID) { simpleAnimeData in
                animeStatus = simpleAnimeData?.data.Media.status
                print("animeStatus", animeStatus)
                FirebaseStoreFunc.shared.getAnimeRecord(userUID: userUID, animeID: animeID) { favorite, notify, _, error in
                    self.currentLongPressCellStatus = (favorite == nil ? false : favorite, notify == nil ? false : notify, animeStatus, animeID)
                    if let favorite = favorite {
                        if favorite { // favorite == true
                            self.favoriteBtn = self.setConfigButton(backgroundColor: .systemYellow, tintColor: .white, buttonImage: UIImage(systemName: "star.fill"), isTrue: true)
                        } else { // favorite == false
                            self.favoriteBtn = self.setConfigButton(backgroundColor: .systemYellow, tintColor: .white, buttonImage: UIImage(systemName: "star.fill"), isTrue: false)
                        }
                    } else { // favorite == nil
                        self.favoriteBtn = self.setConfigButton(backgroundColor: .systemYellow, tintColor: .white, buttonImage: UIImage(systemName: "star.fill"), isTrue: false)
                    }
                    
                    if let notify = notify {
                        if notify { // notify == true
                            self.notifyBtn = self.setConfigButton(backgroundColor: .systemBlue, tintColor: .white, buttonImage: UIImage(systemName: "bell.fill"), isTrue: true)
                        } else { // notify == false
                            self.notifyBtn = self.setConfigButton(backgroundColor: .systemBlue, tintColor: .white, buttonImage: UIImage(systemName: "bell.fill"), isTrue: false)
                        }
                    } else { // notify == nil
                        self.notifyBtn = self.setConfigButton(backgroundColor: .systemBlue, tintColor: .white, buttonImage: UIImage(systemName: "bell.fill"), isTrue: false)
                    }
                    
                    self.favoriteBtn.addTarget(self, action: #selector(self.favoriteBtnTap), for: .touchUpInside)
                    self.notifyBtn.addTarget(self, action: #selector(self.notifyBtnTap), for: .touchUpInside)
                    
                    let cellCurrentX = cell.center.x
                    let cellCurrentY = cell.center.y
                    let viewCenterX = self.view.center.x
                    let viewCenterY = self.view.center.y
                    let transform = CGAffineTransform(translationX: cellCurrentX > viewCenterX ? -(cellCurrentX - viewCenterX) : viewCenterX - cellCurrentX, y: cellCurrentY > viewCenterY ? -(cellCurrentY - viewCenterY) : viewCenterY - cellCurrentX)
                    let blurEffect = UIBlurEffect(style: .light)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.frame = self.view.bounds
                    blurEffectView.tag = 999
                    self.view.addSubview(blurEffectView)
                    let tapToDismiss = UITapGestureRecognizer(target: self, action: #selector(self.closeBlurView))
                    blurEffectView.addGestureRecognizer(tapToDismiss)
                    let cellSnapShot = cell.snapshotView(afterScreenUpdates: true)
                    cellSnapShot?.frame = cell.convert(cell.bounds, to: self.view)
                    cellSnapShot?.center = self.view.center
                    cellSnapShot?.alpha = 0.0
                    cellSnapShot?.tag = 998
                    self.view.addSubview(cellSnapShot!)
                    let buttonStackView = UIStackView(arrangedSubviews: self.currentLongPressCellStatus.status == "RELEASING" ? [self.favoriteBtn, self.notifyBtn] : [self.favoriteBtn])
                    buttonStackView.axis = .horizontal
                    buttonStackView.spacing = 30
                    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
                    buttonStackView.tag = 997
                    self.view.addSubview(buttonStackView)
                    buttonStackView.topAnchor.constraint(equalTo: cellSnapShot!.bottomAnchor, constant: 20).isActive = true
                    buttonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                    UIView.animate(withDuration: 0.1) {
                        cell.transform = transform
                    } completion: { complete in
                        UIView.animate(withDuration: 0.1) {
                            cellSnapShot?.alpha = 1.0
                        }
                    }
                }
            }
            
        }
        

    }
    
    func removeBlur(cell: UICollectionViewCell) {
        self.view.viewWithTag(999)?.removeFromSuperview()
        self.view.viewWithTag(998)?.removeFromSuperview()
        self.view.viewWithTag(997)?.removeFromSuperview()
        UIView.animate(withDuration: 0.1) {
            cell.transform = .identity
        }
    }
    
    @objc func cellLongTap(sender: AnimeCellLongPressGesture) {
        switch sender.state {
        case .possible:
            break
        case .began:
            let location = sender.location(in: trendingCollectionView)
            let selectedIndexPath = trendingCollectionView.indexPathForItem(at: location)
            selectedAnimeCell = trendingCollectionView.cellForItem(at: selectedIndexPath!)
            for cell in trendingCollectionView.visibleCells {
                if cell == selectedAnimeCell {
                    applyBlur(cell: cell, animeID: sender.animeID)
                }
            }
        case .changed:
            break
        case .ended:
            break
        case .cancelled:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as! SearchingAnimeCollectionViewCell
        
        if let animeAllData = animeFetchedData {
            let animeData = animeAllData.data.Page.media[indexPath.item]
            let longTapGesture = AnimeCellLongPressGesture(target: self, action: #selector(cellLongTap), animeID: animeData.id)
            cell.addGestureRecognizer(longTapGesture)
            if let animeTitle = animeData.title.native {
                cell.setup(title: animeTitle, imageURL: animeData.coverImage.extraLarge)
            } else if let animeTitle = animeData.title.english {
                cell.setup(title: animeTitle, imageURL: animeData.coverImage.extraLarge)
            } else if let animeTitle = animeData.title.romaji {
                cell.setup(title: animeTitle, imageURL: animeData.coverImage.extraLarge)
            }
        } else {
            cell.setup(title: "", imageURL: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let animeData = self.animeFetchedData?.data.Page.media[indexPath.item] {
            AnimeDataFetcher.shared.fetchAnimeByID(id: animeData.id) { mediaResponse in
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
            
//            let detailViewController = AnimeDetailViewController(animeFetchingDataManager: animeFetchManager, mediaID: animeData.id)
//            navigationController?.pushViewController(detailViewController, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

extension TrendingPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 20 // Adjusting width with some padding
        let height: CGFloat = 350  // Fixed height for each cell
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 10)
    }
}
extension TrendingPageViewController: AnimeDataDelegate {
    func passAnimeData(animeData: AnimeSearchedOrTrending) {
        if self.animeFetchedData == nil {
            self.animeFetchedData = animeData
            DispatchQueue.main.async {
                self.trendingCollectionView.reloadData()
            }
        } else {
            let dataLengthBeforeAppend = self.animeFetchedData?.data.Page.media.count ?? 0
            self.animeFetchedData?.data.Page.media.append(contentsOf: animeData.data.Page.media)
            let dataLengthAfterAppend = self.animeFetchedData?.data.Page.media.count ?? 0
            
            let indexPaths = (dataLengthBeforeAppend..<dataLengthAfterAppend).map { IndexPath(item: $0, section: 0) }
            DispatchQueue.main.async {
                self.trendingCollectionView.performBatchUpdates({
                    self.trendingCollectionView.insertItems(at: indexPaths)
                }, completion: nil)
            }
            AnimeDataFetcher.shared.isFetchingData = false
        }
    }
    
    
}
extension TrendingPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let lastTimeFetchData = lastFetchData {
            if Date.now.timeIntervalSince(lastTimeFetchData) < 2 {
                return
            }
                
        }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
//        print("offsetY: \(offsetY)", "contentHeight: \(contentHeight)", "frameHeight: \(frameHeight)")
        if offsetY > contentHeight - frameHeight {
            if let animeFetchedData = animeFetchedData {
                print(AnimeDataFetcher.shared.isFetchingData.description)
                if animeFetchedData.data.Page.pageInfo.hasNextPage {
                    print("fetch data")
                    lastFetchData = Date.now
                    AnimeDataFetcher.shared.fetchAnimeByTrending(page: AnimeDataFetcher.shared.trendingNextFetchPage)
                }
            }
        }
    }
}

extension TrendingPageViewController: AnimeOverViewDataDelegate {
    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media) {
        DispatchQueue.main.async {
            let vc = AnimeDetailViewController(mediaID: media.id)
            vc.animeDetailData = media
            vc.navigationItem.title = media.title.native
            vc.animeDetailView = AnimeDetailView(frame: self.view.frame)
            vc.showOverviewView(sender: vc.animeDetailView.animeBannerView.overviewButton)
            vc.fastNavigate = self.tabBarController.self as? any NavigateDelegate
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        print("load view")
        
    }
    
    
}

class AnimeCellLongPressGesture: UILongPressGestureRecognizer {
    var animeID: Int!
    
    init(target: Any?, action: Selector?, animeID: Int) {
        super.init(target: target, action: action)
        self.animeID = animeID
    }
}

//extension TrendingPageViewController: UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return RightSwipeDismissPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//}
