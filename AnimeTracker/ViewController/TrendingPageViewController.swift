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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        AnimeDataFetcher.shared.animeOverViewDataDelegate = self
        AnimeDataFetcher.shared.animeDataDelegateManager = self
        AnimeDataFetcher.shared.fetchAnimeByTrending(page: AnimeDataFetcher.shared.trendingNextFetchPage)
        AnimeDataFetcher.shared.isFetchingData = false
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trendingCell", for: indexPath) as! SearchingAnimeCollectionViewCell
        if let animeAllData = animeFetchedData {
            let animeData = animeAllData.data.Page.media[indexPath.item]
            print(animeData.title.native)
            cell.setup(title: animeData.title.native, imageURL: animeData.coverImage.extraLarge)
        } else {
            cell.setup(title: "", imageURL: nil)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let animeData = self.animeFetchedData?.data.Page.media[indexPath.item] {
            AnimeDataFetcher.shared.fetchAnimeByID(id: animeData.id)
            
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
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
//        print("offsetY: \(offsetY)", "contentHeight: \(contentHeight)", "frameHeight: \(frameHeight)")
        if offsetY > contentHeight - frameHeight {
            if let animeFetchedData = animeFetchedData {
                print(AnimeDataFetcher.shared.isFetchingData.description)
                if animeFetchedData.data.Page.pageInfo.hasNextPage && !AnimeDataFetcher.shared.isFetchingData {
                    print("fetch data")
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

//extension TrendingPageViewController: UIViewControllerTransitioningDelegate {
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return RightSwipeDismissPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//}
