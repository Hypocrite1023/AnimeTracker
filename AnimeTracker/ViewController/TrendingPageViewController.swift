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
        animeFetchManager.fetchAnimeByTrending()
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
        self.animeFetchedData = animeData
        print("pass data")
        DispatchQueue.main.sync {
            trendingCollectionView.reloadData()
        }
    }
    
    
}
