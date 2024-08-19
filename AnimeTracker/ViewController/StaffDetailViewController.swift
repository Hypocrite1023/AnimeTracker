//
//  StaffDetailViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/16.
//

import UIKit

class StaffDetailViewController: UIViewController {
    @IBOutlet weak var staffDetailScrollView: UIScrollView!
    @IBOutlet weak var staffName: UILabel!
    @IBOutlet weak var staffNickName: UILabel!
    @IBOutlet weak var staffInfo: UILabel! {
        didSet {
            staffInfo.numberOfLines = 0
        }
    }
    @IBOutlet weak var staffCoverImage: UIImageView!
    @IBOutlet weak var staffAnimeCollectionView: UICollectionView! {
        didSet {
            staffAnimeCollectionView.dataSource = self
        }
    }
    @IBOutlet weak var staffMangaCollectionView: UICollectionView! {
        didSet {
            staffMangaCollectionView.dataSource = self
        }
    }
    
    var staffData: StaffDetailData.StaffData.Staff?
    var staffAnimeData: [StaffDetailData.StaffData.Staff.StaffMedia.Edge] = []
    var staffMangaData: [StaffDetailData.StaffData.Staff.StaffMedia.Edge] = []
    
    weak var fastNavigate: NavigateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.isNavigationBarHidden = false
        staffName.text = staffData?.name.native
        staffNickName.text = staffData?.primaryOccupations.joined(separator: ", ")
        staffCoverImage.loadImage(from: staffData?.image.large)
        staffInfo.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: staffData?.description ?? "")
        
        FloatingButtonManager.shared.addToView(toView: self.view)
        FloatingButtonManager.shared.bringFloatingButtonToFront(in: self.view)
        
        staffAnimeCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let staffData = staffData {
            staffAnimeData = staffData.staffMedia.edges.compactMap({ staffMedia in
                if staffMedia.node.type.uppercased() == "Anime".uppercased() {
                    return staffMedia
                } else {
                    return nil
                }
            })
            staffMangaData = staffData.staffMedia.edges.compactMap({ staffMedia in
                if staffMedia.node.type.uppercased() == "Manga".uppercased() {
                    return staffMedia
                } else {
                    return nil
                }
            })
        }
        
    }

}

extension StaffDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == staffAnimeCollectionView {
            return staffAnimeData.count
        }
        if collectionView == staffMangaCollectionView {
            return staffMangaData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == staffAnimeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffAnimeCollectionViewCell", for: indexPath) as! StaffCollectionViewCell
            cell.animeCoverImage.loadImage(from: staffAnimeData[indexPath.item].node.coverImage.large)
            cell.animeTitle.text = staffAnimeData[indexPath.item].node.title.native
            cell.staffTypeInAnime.text = staffAnimeData[indexPath.item].staffRole
            cell.workType = .anime
//            cell.id = staffAnimeData[indexPath.item].id
            return cell
        }
        if collectionView == staffMangaCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffMangaCollectionViewCell", for: indexPath) as! StaffCollectionViewCell
            cell.animeCoverImage.loadImage(from: staffMangaData[indexPath.item].node.coverImage.large)
            cell.animeTitle.text = staffMangaData[indexPath.item].node.title.native
            cell.staffTypeInAnime.text = staffMangaData[indexPath.item].staffRole
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
            AnimeDataFetcher.shared.fetchAnimeByID(id: staffAnimeData[indexPath.item].node.id)
        }
    }
}
