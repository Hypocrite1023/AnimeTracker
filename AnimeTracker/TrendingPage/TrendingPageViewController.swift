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
    private let viewModel: TrendingPageViewModel = TrendingPageViewModel()
    
    private let isScrollingPassThroughSubject: PassthroughSubject<Bool, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    var fetchingDataIndicator = UIActivityIndicatorView(style: .large)
    
    var favoriteBtn: UIButton!, notifyBtn: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        trendingCollectionView.register(UINib(nibName: "TrendingAnimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrendingCollectionViewCell")
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        let spacing = 10
        let width = (Int(UIScreen.main.bounds.width) - 2 * spacing) / 2
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: width * 2)
        collectionViewFlowLayout.minimumInteritemSpacing = CGFloat(spacing)
        trendingCollectionView.collectionViewLayout = collectionViewFlowLayout
        
        viewModel.$animeTrendingData
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.trendingCollectionView.reloadData()
            }
            .store(in: &cancellables)
        
        isScrollingPassThroughSubject
            .removeDuplicates()
            .map { bool -> AnyPublisher<Bool, Never> in
                if bool == false {
                    Just(bool)
                        .delay(for: 2, scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                } else {
                    Just(bool)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isScrolling in
                if isScrolling {
                    self?.navigationController?.setNavigationBarHidden(true, animated: true)
                } else {
                    self?.navigationController?.setNavigationBarHidden(false, animated: true)
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("TrendingPageViewController deinit")
    }
}
extension TrendingPageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.animeTrendingData?.data.page.media.count ?? 0
    }
    
    @objc func closeBlurView() {
        if let selectedAnimeCell = viewModel.selectedAnimeCell {
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
            self.viewModel.currentLongPressCellStatus.isFavorite?.toggle()
            if let favorite = self.viewModel.currentLongPressCellStatus.isFavorite {
                self.favoriteBtn.backgroundColor = favorite ? .systemYellow.withAlphaComponent(0.7) : .secondaryLabel
                self.favoriteBtn.tintColor = favorite ? .white.withAlphaComponent(1) : .white.withAlphaComponent(0.5)
            } else {
                self.viewModel.currentLongPressCellStatus.isFavorite = true
                self.favoriteBtn.backgroundColor = .systemYellow.withAlphaComponent(0.7)
                self.favoriteBtn.tintColor = .white.withAlphaComponent(1)
            }
            if let userUID = Auth.auth().currentUser?.uid, let animeID = self.viewModel.currentLongPressCellStatus.animeID {
                FirebaseManager.shared.addAnimeRecord(userUID: userUID, animeID: animeID, isFavorite: self.viewModel.currentLongPressCellStatus.isFavorite!, isNotify: self.viewModel.currentLongPressCellStatus.isNotify!, status: self.viewModel.currentLongPressCellStatus.status ?? "") { isSuccess, error in
                    print("Is success?", isSuccess)
                }
            }
        }
    }
    
    @objc func notifyBtnTap() {
        DispatchQueue.main.async {
            self.viewModel.currentLongPressCellStatus.isNotify?.toggle()
            if let notify = self.viewModel.currentLongPressCellStatus.isNotify {
                self.notifyBtn.backgroundColor = notify ? .systemBlue.withAlphaComponent(0.7) : .secondaryLabel
                self.notifyBtn.tintColor = notify ? .white.withAlphaComponent(1) : .white.withAlphaComponent(0.5)
            } else {
                self.viewModel.currentLongPressCellStatus.isNotify = true
                self.notifyBtn.backgroundColor = .systemBlue.withAlphaComponent(0.7)
                self.notifyBtn.tintColor = .white.withAlphaComponent(1)
            }
            if let userUID = Auth.auth().currentUser?.uid, let animeID = self.viewModel.currentLongPressCellStatus.animeID {
                FirebaseManager.shared.addAnimeRecord(userUID: userUID, animeID: animeID, isFavorite: self.viewModel.currentLongPressCellStatus.isFavorite!, isNotify: self.viewModel.currentLongPressCellStatus.isNotify!, status: self.viewModel.currentLongPressCellStatus.status ?? "") { isSuccess, error in
                    print("Is success?", isSuccess)
                }
            }
            if self.viewModel.currentLongPressCellStatus.isNotify! {
                AnimeDataFetcher.shared.fetchAnimeEpisodeDataByID(id: self.viewModel.currentLongPressCellStatus.animeID!) { episodeData in
                    if let nextAiringEpisode = episodeData?.data.Media.nextAiringEpisode, let episodes = episodeData?.data.Media.episodes, let animeTitle = episodeData?.data.Media.title.native {
                        AnimeNotification.shared.setupAllEpisodeNotification(animeID: self.viewModel.currentLongPressCellStatus.animeID!, animeTitle: animeTitle, nextAiringEpsode: nextAiringEpisode.episode, nextAiringInterval: TimeInterval(nextAiringEpisode.timeUntilAiring), totalEpisode: episodes)
                    }
                }
            } else {
                AnimeNotification.shared.removeAllEpisodeNotification(for: self.viewModel.currentLongPressCellStatus.animeID!)
            }
        }
    }
    
    func applyBlur(cell: UICollectionViewCell, animeID: Int) {
        if let userUID = Auth.auth().currentUser?.uid {
            var animeStatus: String?
            AnimeDataFetcher.shared.fetchAnimeSimpleDataByID(id: animeID)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                        
                    case .finished:
                        break
                    case .failure(let error):
                        print(error)
                    }
                } receiveValue: { simpleAnimeData in
                    animeStatus = simpleAnimeData.data.Media.status
                    FirebaseManager.shared.getAnimeRecord(userUID: userUID, animeID: animeID) { favorite, notify, _, error in
                        self.viewModel.currentLongPressCellStatus = (favorite == nil ? false : favorite, notify == nil ? false : notify, animeStatus, animeID)
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
                        let buttonStackView = UIStackView(arrangedSubviews: self.viewModel.currentLongPressCellStatus.status == "RELEASING" ? [self.favoriteBtn, self.notifyBtn] : [self.favoriteBtn])
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
                .store(in: &cancellables)
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
            viewModel.selectedAnimeCell = trendingCollectionView.cellForItem(at: selectedIndexPath!)
            for cell in trendingCollectionView.visibleCells {
                if cell == viewModel.selectedAnimeCell {
                    applyBlur(cell: cell, animeID: sender.animeID)
                    print("applyBlur")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCollectionViewCell", for: indexPath) as! TrendingAnimeCollectionViewCell
        
        if let animeAllData = viewModel.animeTrendingData {
            let animeData = animeAllData.data.page.media[indexPath.item]
            let longTapGesture = AnimeCellLongPressGesture(target: self, action: #selector(cellLongTap), animeID: animeData.id)
            cell.addGestureRecognizer(longTapGesture)
            if let animeTitle = animeData.title.native {
                cell.setCell(title: animeTitle, imageURL: animeData.coverImage.extraLarge)
            } else if let animeTitle = animeData.title.english {
                cell.setCell(title: animeTitle, imageURL: animeData.coverImage.extraLarge)
            } else if let animeTitle = animeData.title.romaji {
                cell.setCell(title: animeTitle, imageURL: animeData.coverImage.extraLarge)
            }
        } else {
            cell.setCell(title: "", imageURL: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let animeData = viewModel.animeTrendingData?.data.page.media[indexPath.item] {
            let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(identifier: "AnimeDetailView") as! AnimeDetailPageViewController
            vc.viewModel = AnimeDetailPageViewModel(animeID: animeData.id)
            navigationController?.pushViewController(vc, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}

extension TrendingPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let lastTimeFetchData = viewModel.lastFetchDateTime {
            if Date.now.timeIntervalSince(lastTimeFetchData) < 2 {
                return
            }
                
        }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
//        print("offsetY: \(offsetY)", "contentHeight: \(contentHeight)", "frameHeight: \(frameHeight)")
        if offsetY > contentHeight - frameHeight {
            if let hasNextPage = viewModel.animeTrendingData?.data.page.pageInfo.hasNextPage {
                if hasNextPage {
                    viewModel.lastFetchDateTime = .now
                    viewModel.fetchMoreTrendingAnimeData()
                }
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollingPassThroughSubject.send(true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrollingPassThroughSubject.send(false)
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
