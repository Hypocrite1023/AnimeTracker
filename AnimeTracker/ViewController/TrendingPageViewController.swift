//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/18.
//

import UIKit

class TrendingPageViewController: UIViewController {
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    var animeFetchManager = AnimeFetchData()
    var animeFetchedData: AnimeSearchedOrTrending?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        animeFetchManager.animeDataDelegateManager = self
        animeFetchManager.fetchAnimeByTrending(page: animeFetchManager.trendingNextFetchPage)
        animeFetchManager.isFetchingData = false
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
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
            let detailViewController = AnimeDetailViewController(animeFetchingDataManager: animeFetchManager, mediaID: animeData.id)
            detailViewController.modalPresentationStyle = .formSheet
            present(detailViewController, animated: true)
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
            animeFetchManager.isFetchingData = false
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
                print(animeFetchManager.isFetchingData.description)
                if animeFetchedData.data.Page.pageInfo.hasNextPage && !animeFetchManager.isFetchingData {
                    print("fetch data")
                    animeFetchManager.fetchAnimeByTrending(page: animeFetchManager.trendingNextFetchPage)
                }
            }
        }
    }
}
