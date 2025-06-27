//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/18.
//

import UIKit
import Combine


class TrendingPageViewController: UIViewController {
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()
    private let viewModel: TrendingPageViewModel = TrendingPageViewModel()
    
    private let isScrollingPassThroughSubject: PassthroughSubject<Bool, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    var fetchingDataIndicator = UIActivityIndicatorView(style: .large)
    
    var favoriteBtn: UIButton!, notifyBtn: UIButton!
    
    private var lastContentOffsetY: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubscrition()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lastContentOffsetY = trendingCollectionView.contentOffset.y
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        trendingCollectionView.register(UINib(nibName: "TrendingAnimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TrendingCollectionViewCell")
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        let spacing = 10
        let width = (Int(UIScreen.main.bounds.width) - 3 * spacing) / 3
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: width * 2)
        collectionViewFlowLayout.minimumInteritemSpacing = CGFloat(spacing)
        trendingCollectionView.collectionViewLayout = collectionViewFlowLayout
        
        trendingCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTrendingData), for: .valueChanged)
        trendingCollectionView.accessibilityIdentifier = "trendingCollectionView"
    }
    
    private func setupSubscrition() {
        viewModel.$animeTrendingData
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.trendingCollectionView.reloadData()
                self.refreshControl.endRefreshing()
            }
            .store(in: &cancellables)
        
        viewModel.shouldNavigateToDetailPage
            .sink { animeId in
                let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(identifier: "AnimeDetailView") as! AnimeDetailPageViewController
                vc.viewModel = AnimeDetailPageViewModel(animeID: animeId)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc func closeBlurView() {
        if let selectedAnimeCell = viewModel.selectedAnimeCell {
            removeBlur(cell: selectedAnimeCell)
        }
    }
    
    @objc func refreshTrendingData() {
        self.viewModel.shouldRefreshTrendingData.send(())
    }
    
    func setConfigButton(backgroundColor: UIColor, tintColor: UIColor, buttonImage: UIImage?, isTrue: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle("", for: .normal)
        button.backgroundColor = isTrue ? backgroundColor.withAlphaComponent(1) : .secondaryLabel
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
        return button
    }
    
    @objc func favoriteBtnTap() {
        DispatchQueue.main.async {
            guard let animeID = self.viewModel.currentLongPressCellStatus.animeID,
                  let isNotify = self.viewModel.currentLongPressCellStatus.isNotify,
                  let status = self.viewModel.currentLongPressCellStatus.status else {
                AlertWithMessageController.setupAlertController(title: "Error", message: "Anime data not available.", viewController: self)
                return
            }

            if FirebaseManager.shared.getCurrentUserUID() == nil {
                self.showLoginAlert()
                return
            }

            self.viewModel.currentLongPressCellStatus.isFavorite?.toggle()
            let isFavorite = self.viewModel.currentLongPressCellStatus.isFavorite ?? true // Default to true if nil

            self.updateConfigButton(btn: self.favoriteBtn, isTrue: isFavorite)

            self.viewModel.createOrUpdateAnimeRecord()
                .receive(on: DispatchQueue.main)
                .timeout(10, scheduler: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        AlertWithMessageController.setupAlertController(title: "Error", message: error.localizedDescription, viewController: self)
                    }
                } receiveValue: { _ in
                    // Handle success if needed
                }
                .store(in: &self.cancellables)
        }
    }
    
    @objc func notifyBtnTap() {
        DispatchQueue.main.async {
            guard let animeID = self.viewModel.currentLongPressCellStatus.animeID,
                  let isFavorite = self.viewModel.currentLongPressCellStatus.isFavorite,
                  let status = self.viewModel.currentLongPressCellStatus.status else {
                AlertWithMessageController.setupAlertController(title: "Error", message: "Anime data not available.", viewController: self)
                return
            }

            if FirebaseManager.shared.getCurrentUserUID() == nil {
                self.showLoginAlert()
                return
            }

            self.viewModel.currentLongPressCellStatus.isNotify?.toggle()
            let isNotify = self.viewModel.currentLongPressCellStatus.isNotify ?? true // Default to true if nil

            self.updateConfigButton(btn: self.notifyBtn, isTrue: isNotify)

            if isNotify {
                self.viewModel.createLocolNotification()
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            if let error = error as? LocolNotificationError {
                                AlertWithMessageController.setupAlertController(title: "Setting notification error", message: error.description, viewController: self)
                            } else {
                                AlertWithMessageController.setupAlertController(title: "Setting notification error", message: error.localizedDescription, viewController: self)
                            }
                        }
                    } receiveValue: { _ in
                        // Handle success if needed
                    }
                    .store(in: &self.cancellables)
            } else {
                self.viewModel.removeLocolNotification()
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            if let error = error as? LocolNotificationError {
                                AlertWithMessageController.setupAlertController(title: "Setting notification error", message: error.description, viewController: self)
                            }
                        }
                    } receiveValue: { _ in
                        // Handle success if needed
                    }
                    .store(in: &self.cancellables)
            }

            self.viewModel.createOrUpdateAnimeRecord()
                .receive(on: DispatchQueue.main)
                .timeout(10, scheduler: RunLoop.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        AlertWithMessageController.setupAlertController(title: "Error", message: error.localizedDescription, viewController: self)
                    }
                } receiveValue: { _ in
                    // Handle success if needed
                }
                .store(in: &self.cancellables)
        }
    }
    
    private func updateConfigButton(btn: UIButton, isTrue: Bool) {
        if btn == notifyBtn {
            btn.backgroundColor = isTrue ? .systemBlue.withAlphaComponent(1) : .secondaryLabel
            btn.tintColor = .white.withAlphaComponent(isTrue ? 1 : 0.5)
        } else if btn == favoriteBtn {
            btn.backgroundColor = isTrue ? .systemYellow.withAlphaComponent(1) : .secondaryLabel
            btn.tintColor = .white.withAlphaComponent(isTrue ? 1 : 0.5)
        }
        
    }
    
    func applyBlur(cell: UICollectionViewCell, animeID: Int) {
        var animeStatus: String?
        AnimeDataFetcher.shared.fetchAnimeSimpleDataByID(id: animeID)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching anime record: \(error.localizedDescription)")
                    // Handle error, perhaps set default values or show an alert
                }
            } receiveValue: { (simpleAnimeData) in
                animeStatus = simpleAnimeData.status
                
                // Always initialize buttons, assuming not favorited/notified if not logged in or no record
                self.favoriteBtn = self.setConfigButton(backgroundColor: .systemYellow, tintColor: .white, buttonImage: UIImage(systemName: "star.fill"), isTrue: false)
                self.notifyBtn = self.setConfigButton(backgroundColor: .systemBlue, tintColor: .white, buttonImage: UIImage(systemName: "bell.fill"), isTrue: false)
                
                if let userUID = FirebaseManager.shared.getCurrentUserUID() {
                    FirebaseManager.shared.getAnimeRecord(userUID: userUID, animeID: animeID)
                        .receive(on: DispatchQueue.main)
                        .sink { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print("Error fetching anime record: \(error.localizedDescription)")
                            }
                        } receiveValue: { (favorite, notify, status) in
                            self.viewModel.currentLongPressCellStatus = (favorite, notify, animeStatus, animeID)
                            
                            if let favorite = favorite {
                                self.updateConfigButton(btn: self.favoriteBtn, isTrue: favorite)
                            }
                            if let notify = notify {
                                self.updateConfigButton(btn: self.notifyBtn, isTrue: notify)
                            }
                        }
                        .store(in: &self.cancellables)
                } else {
                    // If not logged in, set default status for display
                    self.viewModel.currentLongPressCellStatus = (false, false, animeStatus, animeID)
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
                guard let cellSnapShot = cell.snapshotView(afterScreenUpdates: true) else { return }
                
                let cellSnapShotWithPaddingContainer = UIView()
                cellSnapShotWithPaddingContainer.backgroundColor = .white
                cellSnapShotWithPaddingContainer.layer.cornerRadius = 10
                cellSnapShotWithPaddingContainer.clipsToBounds = true
                
                cellSnapShotWithPaddingContainer.addSubview(cellSnapShot)
                cellSnapShot.translatesAutoresizingMaskIntoConstraints = false
                cellSnapShot.widthAnchor.constraint(equalToConstant: cellSnapShot.bounds.width).isActive = true
                cellSnapShot.heightAnchor.constraint(equalToConstant: cellSnapShot.bounds.height).isActive = true
                cellSnapShot.centerXAnchor.constraint(equalTo: cellSnapShotWithPaddingContainer.centerXAnchor).isActive = true
                cellSnapShot.centerYAnchor.constraint(equalTo: cellSnapShotWithPaddingContainer.centerYAnchor).isActive = true
                
                cellSnapShotWithPaddingContainer.alpha = 0.0
                cellSnapShotWithPaddingContainer.tag = 998
                cellSnapShot.alpha = 0.0
                cellSnapShot.tag = 997
                self.view.addSubview(cellSnapShotWithPaddingContainer)
                cellSnapShotWithPaddingContainer.translatesAutoresizingMaskIntoConstraints = false
                cellSnapShotWithPaddingContainer.widthAnchor.constraint(equalToConstant: cellSnapShot.bounds.width + 20).isActive = true
                cellSnapShotWithPaddingContainer.heightAnchor.constraint(equalToConstant: cellSnapShot.bounds.height + 20).isActive = true
                cellSnapShotWithPaddingContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                cellSnapShotWithPaddingContainer.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
                let buttonStackView = UIStackView(arrangedSubviews: self.viewModel.currentLongPressCellStatus.status == "RELEASING" ? [self.favoriteBtn, self.notifyBtn] : [self.favoriteBtn])
                buttonStackView.axis = .horizontal
                buttonStackView.spacing = 30
                buttonStackView.translatesAutoresizingMaskIntoConstraints = false
                buttonStackView.tag = 996
                self.view.addSubview(buttonStackView)
                buttonStackView.topAnchor.constraint(equalTo: cellSnapShotWithPaddingContainer.bottomAnchor, constant: 20).isActive = true
                buttonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                UIView.animate(withDuration: 0.1) {
                    cell.transform = transform
                } completion: { complete in
                    UIView.animate(withDuration: 0.1) {
                        cellSnapShotWithPaddingContainer.alpha = 1.0
                        cellSnapShot.alpha = 1.0
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func removeBlur(cell: UICollectionViewCell) {
        self.view.viewWithTag(999)?.removeFromSuperview()
        self.view.viewWithTag(998)?.removeFromSuperview()
        self.view.viewWithTag(997)?.removeFromSuperview()
        self.view.viewWithTag(996)?.removeFromSuperview()
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
    
    func showLoginAlert() {
        let alertController = UIAlertController(title: "Login Required", message: "You need to be logged in to perform this action.", preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { _ in
            // Navigate to login page
            let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
        }
        alertController.addAction(loginAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Keep the blur view and buttons visible
        }
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    deinit {
        print("TrendingPageViewController deinit")
    }
}
// MARK: - UICollectionViewDataSource
extension TrendingPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.animeTrendingData?.data.page.media.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCollectionViewCell", for: indexPath) as! TrendingAnimeCollectionViewCell
        
        if let animeAllData = viewModel.animeTrendingData {
            let animeData = animeAllData.data.page.media[indexPath.item]
            let longTapGesture = AnimeCellLongPressGesture(target: self, action: #selector(cellLongTap), animeID: animeData.id)
            cell.addGestureRecognizer(longTapGesture)
            if let animeTitle = animeData.title.native {
                cell.setCell(title: animeTitle, imageURL: animeData.coverImage?.large)
            } else if let animeTitle = animeData.title.english {
                cell.setCell(title: animeTitle, imageURL: animeData.coverImage?.large)
            } else if let animeTitle = animeData.title.romaji {
                cell.setCell(title: animeTitle, imageURL: animeData.coverImage?.large)
            }
        } else {
            cell.setCell(title: "", imageURL: nil)
        }
        return cell
    }
    
}
// MARK: - UICollectionViewDelegate
extension TrendingPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let animeData = viewModel.animeTrendingData?.data.page.media[indexPath.item] {
            viewModel.animeCollectionViewCellTap.send(animeData.id)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
// MARK: - UIScrollViewDelegate
extension TrendingPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == trendingCollectionView {
            if let lastContentOffsetY = self.lastContentOffsetY, scrollView.contentOffset.y > 0 {
                if scrollView.contentOffset.y > lastContentOffsetY + 30 {
                    self.lastContentOffsetY = scrollView.contentOffset.y
                    navigationController?.setNavigationBarHidden(true, animated: true)
                    setTabBar(hidden: true, animated: true)
                } else if scrollView.contentOffset.y < lastContentOffsetY - 30 {
                    self.lastContentOffsetY = scrollView.contentOffset.y
                    navigationController?.setNavigationBarHidden(false, animated: true)
                    setTabBar(hidden: false, animated: true)
                }
            }
            
            
            guard let hasNextPage = viewModel.animeTrendingData?.data.page.pageInfo.hasNextPage, hasNextPage else { return }
            
            let offsetY = scrollView.contentOffset.y // 當前scroll view滑到的offset 畫面左上角
            let contentHeight = scrollView.contentSize.height // 當前scroll view可滑動的大小
            let frameHeight = scrollView.frame.size.height // scroll view畫面大小
            let cellHeight = ((scrollView as! UICollectionView).collectionViewLayout as! UICollectionViewFlowLayout).itemSize.height
//            print("offsetY: \(offsetY)", "contentHeight: \(contentHeight)", "frameHeight: \(frameHeight)", "cellHeight: \(cellHeight)")
            if offsetY + frameHeight >= contentHeight - 20 * cellHeight { // 還沒滑到最下面就先load data
                if let hasNextPage = viewModel.animeTrendingData?.data.page.pageInfo.hasNextPage, hasNextPage {
                    viewModel.shouldLoadMoreTrendingData.send(())
                }
            }
        }
    }
}
// MARK: - config tab bar
extension TrendingPageViewController {
    func setTabBar(hidden: Bool, animated: Bool) {
        guard let tabBar = self.tabBarController?.tabBar else { return }
        let isHidden = tabBar.frame.origin.y >= UIScreen.main.bounds.height
        if hidden == isHidden { return }

        let height = tabBar.frame.size.height
        let offsetY = hidden ? height : -height

        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            tabBar.frame = tabBar.frame.offsetBy(dx: 0, dy: offsetY)
        }
    }
}

class AnimeCellLongPressGesture: UILongPressGestureRecognizer {
    var animeID: Int!
    
    init(target: Any?, action: Selector?, animeID: Int) {
        super.init(target: target, action: action)
        self.animeID = animeID
    }
}
