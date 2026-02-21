//
//  DescriptionPopoverViewController.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/2/21.
//

import UIKit
import SnapKit

class DescriptionPopoverViewController: UIViewController {
    
    private let descriptionText: String
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = descriptionText
        label.numberOfLines = 0
        label.font = .atBody
        label.textColor = .atTextPrimary
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .atSecondaryBackground
        setupLayout()
        calculatePreferredSize()
    }
    
    init(text: String) {
        descriptionText = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
    
    private func calculatePreferredSize() {
        let maxWidth = UIScreen.main.bounds.width * 0.6
        let horizontalPadding: CGFloat = 32 // 16 * 2
        
        // 設定 Label 的最大寬度，讓它知道何時該換行
        descriptionLabel.preferredMaxLayoutWidth = maxWidth - horizontalPadding
        
        // 強制更新佈局，確保 Label 的 intrinsicContentSize 被正確計算
        view.layoutIfNeeded()
        
        // 取得視圖在符合約束條件下的最小尺寸（即貼合內容的大小）
        let size = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        preferredContentSize = size
    }
}
