//
//  CategoryViewController.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2024/12/28.
//

import UIKit

class CategoryViewController: UIViewController {
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        // 設定 UICollectionViewCompositionalLayout
        let layout = createCompositionalLayout()
        categoryCollectionView.collectionViewLayout = layout
        
        // 註冊 Cell
        categoryCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "categoryCell")
//        categoryCollectionView.backgroundColor = .red
        
//        let compositionalLayout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
//            // 根據 sectionIndex 和 layoutEnvironment 動態定義 Section
//        }
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

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        5
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
            return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
                // 每個 Item 的大小
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                
                // 水平方向上的 Group
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(500), heightDimension: .estimated(400))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                // 設定 Section，並使其可以水平滾動
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .paging // 水平滾動行為
                
                return section
            }
        }
}
