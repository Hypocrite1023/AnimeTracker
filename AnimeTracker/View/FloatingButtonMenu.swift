//
//  FloatingButtonMenu.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/6.
//

import UIKit

class FloatingButtonMenu: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var trendingBtn: UIView!
    @IBOutlet weak var searchingBtn: UIView!
    @IBOutlet weak var favoriteBtn: UIView!
    
    weak var navigateDelegate: NavigateDelegate?

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("FloatingButtonMenu", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let goToTrendingPageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 0)
        trendingBtn.addGestureRecognizer(goToTrendingPageGesture)
        let goToSearchingPageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo: 1)
        searchingBtn.addGestureRecognizer(goToSearchingPageGesture)
        let goToFavoritePageGesture = FloatingButtonTapGesture(target: self, action: #selector(navigateTo), navigateTo:2)
        favoriteBtn.addGestureRecognizer(goToFavoritePageGesture)
    }
    @objc func navigateTo(sender: FloatingButtonTapGesture) {
        navigateDelegate?.navigateTo(page: sender.navigateTo)
    }
}

class FloatingButtonTapGesture: UITapGestureRecognizer {
    var navigateTo: Int
    init(target: Any?, action: Selector?, navigateTo: Int) {
        self.navigateTo = navigateTo
        super.init(target: target, action: action)
    }
}

protocol NavigateDelegate: AnyObject {
    ///0: trending, 1: searching, 2: favorite
    func navigateTo(page: Int)
}
