//
//  AnimeDetailViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/19.
//

import UIKit

class AnimeDetailViewController: UIViewController {
    
    var animeFetchingDataManager: AnimeFetchData
    var animeMediaID: Int
    var animeDetailData: MediaResponse.MediaData.Media?
    var animeDetailView: AnimeDetailView!
    
    private lazy var overviewView: OverviewView = {
        let view = OverviewView(frame: .zero)
        view.animeDescriptionDelegate = self
        return view
    }()
    
    init(animeFetchingDataManager: AnimeFetchData, mediaID: Int) {
        self.animeFetchingDataManager = animeFetchingDataManager
        self.animeMediaID = mediaID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.animeFetchingDataManager.animeDetailDataDelegate = self
        animeFetchingDataManager.fetchAnimeByID(id: animeMediaID)
        animeDetailView = AnimeDetailView(frame: self.view.frame)
//        animeDetailView.frame = self.view.frame
        self.view.backgroundColor = .white
        self.view.addSubview(animeDetailView)
        self.setupConstraints()
        self.setupButtonFunctions()
        print("view did load")
        
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("transition")
        animeDetailView.frame = self.view.bounds
    }
    
    private func setupConstraints() {
        let detailButtonWidth = CGFloat(Int(self.view.bounds.width / 3))
        NSLayoutConstraint.activate([
            animeDetailView.animeCoverImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            animeDetailView.animeCoverImageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            animeDetailView.animeCoverImageView.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 0.4),
            animeDetailView.animeCoverImageView.heightAnchor.constraint(equalToConstant: 650 * (self.view.bounds.width * 0.4 / 460)),
            
            animeDetailView.animeTitleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            animeDetailView.animeTitleLabel.leadingAnchor.constraint(equalTo: animeDetailView.animeCoverImageView.trailingAnchor),
            animeDetailView.animeTitleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            animeDetailView.animeTitleLabel.heightAnchor.constraint(equalToConstant: 40),
            
            animeDetailView.essentialInfoLabelStackView.topAnchor.constraint(equalTo: animeDetailView.animeTitleLabel.bottomAnchor, constant: 5),
            animeDetailView.essentialInfoLabelStackView.leadingAnchor.constraint(equalTo: animeDetailView.animeCoverImageView.trailingAnchor, constant: 5),
            animeDetailView.essentialInfoLabelStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            animeDetailView.essentialInfoLabelStackView.heightAnchor.constraint(equalToConstant: 50),
            
            animeDetailView.buttonsScrollView.topAnchor.constraint(equalTo: animeDetailView.animeCoverImageView.bottomAnchor),
            animeDetailView.buttonsScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            animeDetailView.buttonsScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            animeDetailView.buttonsScrollView.heightAnchor.constraint(equalToConstant: 40),
            
            animeDetailView.overviewButton.leadingAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.leadingAnchor),
            animeDetailView.overviewButton.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.topAnchor),
            animeDetailView.overviewButton.bottomAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
            animeDetailView.overviewButton.widthAnchor.constraint(equalToConstant: detailButtonWidth),
//            animeDetailView.overviewButton.heightAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.heightAnchor),

            
            animeDetailView.watchButton.leadingAnchor.constraint(equalTo: animeDetailView.overviewButton.trailingAnchor, constant: 3),
            animeDetailView.watchButton.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.topAnchor),
            animeDetailView.watchButton.bottomAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
            
            animeDetailView.watchButton.widthAnchor.constraint(equalToConstant: detailButtonWidth),
//            animeDetailView.watchButton.heightAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.heightAnchor),
//            animeDetailView.watchButton.trailingAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.trailingAnchor),

            animeDetailView.charactersButton.leadingAnchor.constraint(equalTo: animeDetailView.watchButton.trailingAnchor, constant: 3),
            animeDetailView.charactersButton.widthAnchor.constraint(equalToConstant: detailButtonWidth),
            animeDetailView.charactersButton.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.topAnchor),
            animeDetailView.charactersButton.bottomAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
//            animeDetailView.charactersButton.heightAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.heightAnchor),
            
            animeDetailView.staffButton.leadingAnchor.constraint(equalTo: animeDetailView.charactersButton.trailingAnchor, constant: 3),
            animeDetailView.staffButton.widthAnchor.constraint(equalToConstant: detailButtonWidth),
            animeDetailView.staffButton.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.topAnchor),
            animeDetailView.staffButton.bottomAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
//            animeDetailView.staffButton.heightAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.heightAnchor),
            
            animeDetailView.statsButton.leadingAnchor.constraint(equalTo: animeDetailView.staffButton.trailingAnchor, constant: 3),
            animeDetailView.statsButton.widthAnchor.constraint(equalToConstant: detailButtonWidth),
            animeDetailView.statsButton.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.topAnchor),
            animeDetailView.statsButton.bottomAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
//            animeDetailView.statsButton.heightAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.heightAnchor),
            
            animeDetailView.socialButton.leadingAnchor.constraint(equalTo: animeDetailView.statsButton.trailingAnchor, constant: 3),
            animeDetailView.socialButton.widthAnchor.constraint(equalToConstant: detailButtonWidth),
            animeDetailView.socialButton.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.topAnchor),
            animeDetailView.socialButton.bottomAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
            animeDetailView.socialButton.trailingAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.trailingAnchor),
//            animeDetailView.socialButton.heightAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.heightAnchor),
            
            animeDetailView.differentViewContainer.topAnchor.constraint(equalTo: animeDetailView.buttonsScrollView.bottomAnchor),
            animeDetailView.differentViewContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            animeDetailView.differentViewContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            animeDetailView.differentViewContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func setupButtonFunctions() {
        animeDetailView.overviewButton.addTarget(self, action: #selector(switchToOverviewPage), for: .touchUpInside)
        animeDetailView.watchButton.addTarget(self, action: #selector(switchToWatchPage), for: .touchUpInside)
        animeDetailView.charactersButton.addTarget(self, action: #selector(switchToCharactersPage), for: .touchUpInside)
        animeDetailView.staffButton.addTarget(self, action: #selector(switchToStaffPage), for: .touchUpInside)
        animeDetailView.statsButton.addTarget(self, action: #selector(switchToStatsPage), for: .touchUpInside)
        animeDetailView.socialButton.addTarget(self, action: #selector(switchToSocialPage), for: .touchUpInside)
    }
    @objc func switchToOverviewPage(sender: UIButton) {
        resetButtonColorInScrollViewAndSetSenderColor(sender: sender)
        overviewView.updateAnimeDescription()
        switchContentView(to: overviewView)
    }
    @objc func switchToWatchPage(sender: UIButton) {
        resetButtonColorInScrollViewAndSetSenderColor(sender: sender)
        switchContentView(to: WatchView())
    }
    @objc func switchToCharactersPage(sender: UIButton) {
        resetButtonColorInScrollViewAndSetSenderColor(sender: sender)
        switchContentView(to: CharacterView())
    }
    @objc func switchToStaffPage(sender: UIButton) {
        resetButtonColorInScrollViewAndSetSenderColor(sender: sender)
        switchContentView(to: StaffView())
    }
    @objc func switchToStatsPage(sender: UIButton) {
        resetButtonColorInScrollViewAndSetSenderColor(sender: sender)
        switchContentView(to: StatsView())
    }
    @objc func switchToSocialPage(sender: UIButton) {
        resetButtonColorInScrollViewAndSetSenderColor(sender: sender)
        switchContentView(to: SocialView())
    }
    
    private func resetButtonColorInScrollViewAndSetSenderColor(sender: UIButton) {
        animeDetailView.buttonsScrollView.subviews.forEach { subview in
            if !(subview == sender) {
                subview.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1).withAlphaComponent(0.7)
                subview.layer.borderWidth = 0
            }
        }
        sender.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        sender.layer.borderColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).cgColor
        sender.layer.borderWidth = 3
    }
    
    private func switchContentView(to newview: UIView) {
        animeDetailView.differentViewContainer.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        newview.translatesAutoresizingMaskIntoConstraints = false
        animeDetailView.differentViewContainer.addSubview(newview)
        
        NSLayoutConstraint.activate([
            newview.topAnchor.constraint(equalTo: animeDetailView.differentViewContainer.topAnchor),
            newview.leadingAnchor.constraint(equalTo: animeDetailView.differentViewContainer.leadingAnchor),
            newview.trailingAnchor.constraint(equalTo: animeDetailView.differentViewContainer.trailingAnchor),
            newview.bottomAnchor.constraint(equalTo: animeDetailView.differentViewContainer.bottomAnchor),
        ])
        
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

extension AnimeDetailViewController: AnimeDetailDataDelegate {
    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media) {
        self.animeDetailData = media
        DispatchQueue.main.async {
            self.animeDetailView?.setupAnimeInfoPage(animeDetailData: self.animeDetailData!)
        }
        print("load view")
    }
    
}

extension AnimeDetailViewController: AnimeDescriptionDelegate {
    func passDescriptionAndUpdate() -> String {
        return animeDetailData?.description ?? ""
    }
}
