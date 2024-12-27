//
//  WatchView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/21.
//

import UIKit

class WatchView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var streamingEpisodeCollectionView: UICollectionView!
    var streamingDetailDelegate: AnimeStreamingDetailDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 600, height: 200)
//        streamingEpisodeCollectionView.collectionViewLayout = layout
        streamingEpisodeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        streamingEpisodeCollectionView.register(WatchViewCollectionViewCell.self, forCellWithReuseIdentifier: WatchViewCollectionViewCell.reuseIdentifier)
        streamingEpisodeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        streamingEpisodeCollectionView.dataSource = self
        streamingEpisodeCollectionView.delegate = self
        streamingEpisodeCollectionView.backgroundColor = .clear
        streamingEpisodeCollectionView.layer.borderColor = UIColor.red.cgColor
        streamingEpisodeCollectionView.layer.borderWidth = 5
        self.addSubview(streamingEpisodeCollectionView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupConstraints() {
        streamingEpisodeCollectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        streamingEpisodeCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        streamingEpisodeCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        streamingEpisodeCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
//        streamingEpisodeCollectionView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        streamingEpisodeCollectionView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}

extension WatchView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return streamingDetailDelegate?.passStreamingDetailCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WatchViewCollectionViewCell.reuseIdentifier, for: indexPath) as! WatchViewCollectionViewCell
        if let streamDetail = streamingDetailDelegate?.passStreamingDetail() {
            cell.setupCell(title: streamDetail[indexPath.item].title, imageURL: streamDetail[indexPath.item].thumbnail)
            cell.setupConstraints()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize = CGSize()
        if UIScreen.main.bounds.width > 800 {
            print("here")
            cellSize.width = 350
            cellSize.height = 180
        } else {
            cellSize.width = UIScreen.main.bounds.width - 20
            cellSize.height = 200
        }
        return cellSize
    }
}
