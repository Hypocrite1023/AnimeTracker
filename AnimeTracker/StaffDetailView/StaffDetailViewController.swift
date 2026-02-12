//
//  StaffDetailViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/16.
//

import UIKit
import Combine

class StaffDetailViewController: UIViewController {
    @IBOutlet weak var staffDetailScrollView: UIScrollView!
    @IBOutlet weak var staffName: UILabel!
    @IBOutlet weak var staffNickName: UILabel!
    @IBOutlet weak var staffInfo: UILabel!
    @IBOutlet weak var staffCoverImage: UIImageView!
    @IBOutlet weak var staffAnimeCollectionView: UICollectionView!
    @IBOutlet weak var staffMangaCollectionView: UICollectionView!
    
    var viewModel: StaffDetailViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    weak var fastNavigate: NavigateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        viewModel?.$staffData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] staffData in
                guard let data = staffData else { return }
                self?.setupView(staffData: data)
            })
            .store(in: &cancellables)
        
        viewModel?.$staffAnimeData
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.staffAnimeCollectionView.reloadData()
            })
            .store(in: &cancellables)
        
        viewModel?.$staffMangaData
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.staffMangaCollectionView.reloadData()
            })
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FloatingButtonManager.shared.addToView(toView: self.view)
        FloatingButtonManager.shared.bringFloatingButtonToFront(in: self.view)
    }
    
    private func setupView(staffData: Response.StaffDetailData.StaffData.Staff) {
        staffName.text = staffData.name.native
        staffNickName.text = staffData.primaryOccupations.joined(separator: ", ")
        staffCoverImage.loadImage(from: staffData.image.large)
        staffInfo.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: staffData.description)
        
        staffAnimeCollectionView.delegate = self
        staffMangaCollectionView.delegate = self
        
        staffAnimeCollectionView.dataSource = self
        staffMangaCollectionView.dataSource = self
    }

}

extension StaffDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == staffAnimeCollectionView {
            return viewModel?.staffAnimeData.count ?? 0
        } else if collectionView == staffMangaCollectionView {
            return viewModel?.staffMangaData.count ?? 0
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == staffAnimeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffAnimeCollectionViewCell", for: indexPath) as! StaffCollectionViewCell
            cell.animeCoverImage.loadImage(from: viewModel?.staffAnimeData[indexPath.item].node.coverImage.large)
            cell.animeTitle.text = viewModel?.staffAnimeData[indexPath.item].node.title.native
            cell.staffTypeInAnime.text = viewModel?.staffAnimeData[indexPath.item].staffRole
            cell.workType = .anime
//            cell.id = staffAnimeData[indexPath.item].id
            return cell
        }
        if collectionView == staffMangaCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffMangaCollectionViewCell", for: indexPath) as! StaffCollectionViewCell
            cell.animeCoverImage.loadImage(from: viewModel?.staffMangaData[indexPath.item].node.coverImage.large)
            cell.animeTitle.text = viewModel?.staffMangaData[indexPath.item].node.title.native
            cell.staffTypeInAnime.text = viewModel?.staffMangaData[indexPath.item].staffRole
            cell.workType = .manga
//            cell.id = staffMangaData[indexPath.item].id
            return cell
        }
        return UICollectionViewCell()
    }
    
    
}

extension StaffDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == staffAnimeCollectionView {
//            AnimeDataFetcher.shared.fetchAnimeByID(id: staffAnimeData[indexPath.item].node.id) { mediaResponse in
//                DispatchQueue.main.async {
//                    let media = mediaResponse.data.media
//                    let vc = AnimeDetailViewController(mediaID: media.id)
//                    vc.animeDetailData = media
//                    vc.navigationItem.title = media.title.native
//                    vc.animeDetailView = AnimeDetailView(frame: self.view.frame)
//                    vc.showOverviewView(sender: vc.animeDetailView.animeBannerView.overviewButton)
//                    vc.fastNavigate = self.tabBarController.self as? any NavigateDelegate
//                    
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
        }
    }
}
