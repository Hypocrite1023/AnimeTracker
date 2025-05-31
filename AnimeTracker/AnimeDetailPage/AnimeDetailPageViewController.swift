//
//  AnimeDetailViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/19.
//

import UIKit
import Combine
import FirebaseAuth
import FirebaseFirestoreInternal
import Kingfisher
import SnapKit
import CombineCocoa

class AnimeDetailPageViewController: UIViewController {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var wholePageScrollView: UIScrollView!
    @IBOutlet weak var animeBannerImage: UIImageView!
    @IBOutlet weak var animeThumbnailImage: UIImageView!
    @IBOutlet weak var addAnimeToFavoriteBtn: UIButton!
    @IBOutlet weak var animeAiringNotifyBtn: UIButton!
    @IBOutlet weak var animeTitleLabel: UILabel!
    
    // 各類別項目按鈕
    @IBOutlet weak var contentSwitchBtnScrollView: UIScrollView!
    @IBOutlet weak var showOverViewBtn: UIButton!
    @IBOutlet weak var showWatchBtn: UIButton!
    @IBOutlet weak var showCharactersBtn: UIButton!
    @IBOutlet weak var showStatsBtn: UIButton!
    @IBOutlet weak var showSocialBtn: UIButton!
    @IBOutlet weak var showStaffBtn: UIButton!
    @IBOutlet weak var container: UIView!
    // data property
    var viewModel: AnimeDetailPageViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private var characterData: [MediaResponse.MediaData.Media.CharacterPreview.Edges] = []
    
    let loadMoreStaffDataTrigger: PassthroughSubject<Void, Never> = .init()
    
    private var wholePageScrollViewContentOffsetY: CGFloat = 0
    private var isNavigationBarHidden: Bool = false
    private var swipePopGestureRecognizer: UISwipeGestureRecognizer?
    
    weak var fastNavigate: NavigateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.hidesBarsOnSwipe = true
        
        swipePopGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipePopGestureRecognizer?.direction = .right
        swipePopGestureRecognizer?.delegate = self
        self.view.addGestureRecognizer(swipePopGestureRecognizer!)
        
        let backButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(swipeAction))
        backButton.image = UIImage(systemName: "chevron.backward")
        navigationItem.leftBarButtonItem = backButton
        
        wholePageScrollView.delegate = self
        
        
        setupSubscriber()
        setupPublisher()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        FloatingButtonManager.shared.addToView(toView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupUI() {
        contentSwitchBtnScrollView.layer.cornerRadius = 10
        showContent(showOverViewBtn)
    }
    
    private func setupSubscriber() {
        guard let viewModel = viewModel else { return }
        
        viewModel.showOverview
            .receive(on: DispatchQueue.main)
            .sink { animeDetail in
                self.setupBaseView(data: animeDetail)
                self.setupOverview(data: animeDetail)
            }
            .store(in: &cancellables)
        viewModel.showWatch
            .receive(on: DispatchQueue.main)
            .sink { streamingEpisode in
                self.setupWatch(streamingEpisodes: streamingEpisode)
            }
            .store(in: &cancellables)
        
        viewModel.showCharacters
            .receive(on: DispatchQueue.main)
            .sink { characters in
                self.setupCharacters(characters: characters)
            }
            .store(in: &cancellables)
        
        viewModel.shouldUpdateCharacters
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { characters in
                
                self.viewModel?.animeCharacterData.append(contentsOf: characters)
                guard let container = self.container.subviews.first(where: {$0 is AnimeCharactersView}) as? AnimeCharactersView else { return }
                self.updateCharacters(container: container, edges: characters)
            }
            .store(in: &cancellables)
        
        viewModel.showStats
            .receive(on: DispatchQueue.main)
            .sink { (ranking, stats) in
                guard let ranking, let stats else { return }
                self.setupStats(rankingData: ranking, stats: stats)
            }
            .store(in: &cancellables)
        
        viewModel.showStaffs
            .receive(on: DispatchQueue.main)
            .sink { staffData in
                self.setupStaff(staffData: staffData)
            }
            .store(in: &cancellables)
        
        viewModel.shouldUpdateStaffs
            .receive(on: DispatchQueue.main)
            .sink { staffData in
                guard let container = self.container.subviews.first(where: {$0 is AnimeStaffView}) as? AnimeStaffView else { return }
                self.updateStaffs(container: container, edges: staffData)
            }
            .store(in: &cancellables)
        
        viewModel.configFavoritePublisher
            .receive(on: DispatchQueue.main)
            .sink { isFavorite in
                self.updateFunctionalButton(isOnColor: .systemYellow, for: self.addAnimeToFavoriteBtn, isOn: isFavorite)
            }
            .store(in: &cancellables)
        
        viewModel.configNotificationPublisher
            .receive(on: DispatchQueue.main)
            .sink { isNotify in
                self.updateFunctionalButton(isOnColor: .systemBlue, for: self.animeAiringNotifyBtn, isOn: isNotify)
            }
            .store(in: &cancellables)
    }
    
    private func setupPublisher() {
        addAnimeToFavoriteBtn.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel?.configFavorite.send(())
            }
            .store(in: &cancellables)
        
        animeAiringNotifyBtn.tapPublisher
            .sink { [weak self] _ in
                self?.viewModel?.configNotification.send(())
            }
            .store(in: &cancellables)
    }
    
    @IBAction func showContent(_ sender: UIButton) {
        let currentOffset = wholePageScrollView.contentOffset
        configureButtonsColor(sender: sender, buttonArr: [showOverViewBtn, showStaffBtn, showCharactersBtn, showWatchBtn, showSocialBtn, showStatsBtn])
        for subview in container.subviews {
            subview.removeFromSuperview()
        }
        switch sender {
            case showOverViewBtn:
            viewModel?.shouldShowOverview.send(())
            case showWatchBtn:
            viewModel?.shouldShowWatch.send(())
            case showCharactersBtn:
            viewModel?.shouldShowCharacters.send(())
            case showStatsBtn:
            viewModel?.shouldShowStats.send(())
            case showSocialBtn:
            viewModel?.shouldShowSocial.send(())
            case showStaffBtn:
            viewModel?.shouldShowStaff.send(())
            default:
                break
        }
        wholePageScrollView.layoutIfNeeded()

        // 設定 offset 回原本的位置
        wholePageScrollView.setContentOffset(currentOffset, animated: false)
    }
    
    
    func configureButtonsColor(sender: UIButton, buttonArr: [UIButton]) {
        for button in buttonArr {
            if button != sender {
                DispatchQueue.main.async {
                    button.setTitleColor(.blue.withAlphaComponent(0.6), for: .normal)
                    button.layer.shadowColor = .none
                    button.layer.shadowOpacity = 0
                    button.layer.shadowOffset = .zero
                    button.layer.shadowRadius = 0
                }
                
            } else {
                DispatchQueue.main.async {
                    button.setTitleColor(.blue.withAlphaComponent(0.9), for: .normal)
                    button.layer.shadowColor = UIColor.blue.cgColor
                    button.layer.shadowOpacity = 0.7
                    button.layer.shadowOffset = CGSize(width: 2, height: 5)
                    button.layer.shadowRadius = 4
                }
                
            }
        }
    }
    
    @objc func showSpoiler(sender: UITapGestureRecognizer) {
        print(sender.view.debugDescription)
        guard let blurEffectView = sender.view else {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            blurEffectView.isHidden = true
        }
//        sender.view.isHidden
    }
    
    @objc func swipeAction(sender: UISwipeGestureRecognizer?) {
        print("right swipe")
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UI func
extension AnimeDetailPageViewController {
    // MARK: - Base
    func setupBaseView(data: MediaResponse.MediaData.Media?) {
        guard let data = data else { return }
        backgroundImageView.kf.setImage(with: URL(string: data.coverImage.extraLarge ?? ""))
        animeBannerImage.kf.setImage(with: URL(string: data.bannerImage ?? (viewModel?.animeDetailData?.coverImage.extraLarge ?? "")))
        animeThumbnailImage.kf.setImage(with: URL(string: data.coverImage.extraLarge ?? ""))
        animeTitleLabel.text = data.title.native
        if data.status.uppercased() != "RELEASING".uppercased() {
            self.animeAiringNotifyBtn.isHidden = true
        }
    }
    // MARK: - Overview
    func setupOverview(data: MediaResponse.MediaData.Media?) {
        let overview = Overview()
        container.addSubview(overview)
        overview.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        guard let data = data else { return }
        setupAnimeInformation(overview: overview, animeDetailData: data)
        setupAnimeDescription(overview: overview, animeDetailData: data)
        setupAnimeRelation(overview: overview, animeDetailData: data)
        setupAnimeCharacter(overview: overview, animeDetailData: data)
        setupAnimeStaff(overview: overview, animeDetailData: data)
        setupAnimeStatusDistribution(overview: overview, animeDetailData: data)
        setupAnimeScoreDistriubtionView(overview: overview, animeDetailData: data)
        setupAnimeWatchHStack(overview: overview, animeDetailData: data)
        setupAnimeRecommendationsHStack(overview: overview, animeDetailData: data)
        setupAnimeReviewsVStack(overview: overview, animeDetailData: data)
        setupAnimeExternalLinkVStack(overview: overview, animeDetailData: data)
        setupAnimeTagsVStack(overview: overview, animeDetailData: data)
    }
    // MARK: - Setting up overview sub functions
    func setupAnimeInformation(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        if let nextAiringEpisode = animeDetailData.nextAiringEpisode {
            overview.airingLabel.text =  "Ep \(nextAiringEpisode.episode): \(AnimeDetailFunc.timeLeft(from: nextAiringEpisode.airingAt))"
        } else {
            if animeDetailData.status == "NOT_YET_RELEASED" {
                overview.airingLabel.text = "NOT_YET_RELEASLED"
            } else {
                overview.airingLabel.text = "FINISHED"
            }
        }
        overview.formatLabel.text = animeDetailData.format
        if let episodes = animeDetailData.episodes {
            overview.episodesLabel.text = "\(episodes)"
        } else {
            overview.episodesLabel.text = ""
        }
        if let duration = animeDetailData.duration {
            overview.episodesDurationLabel.text = "\(duration) mins"
        } else {
            overview.episodesDurationLabel.text = ""
        }
        overview.statusLabel.text = animeDetailData.status
        if let year = animeDetailData.startDate.year, let month = animeDetailData.startDate.month, let day = animeDetailData.startDate.day {
            overview.startDateLabel.text = AnimeDetailFunc.startDateString(year: year, month: month, day: day)
        } else {
            overview.startDateLabel.text = ""
        }
        if let season = animeDetailData.season, let seasonYear = animeDetailData.seasonYear {
            overview.seasonLabel.text = "\(season) \(seasonYear)"
        } else {
            overview.seasonLabel.text = ""
        }
        if let averageScore = animeDetailData.averageScore {
            overview.averageScoreLabel.text = "\(averageScore)%"
        } else {
            overview.averageScoreLabel.text = "%"
        }
        if let meanScore = animeDetailData.meanScore {
            overview.meanScoreLabel.text = "\(meanScore)%"
        } else {
            overview.meanScoreLabel.text = ""
        }
        
        overview.popularityLabel.text = "\(animeDetailData.popularity)"
        overview.favoriteLabel.text = "\(animeDetailData.favourites)"
        overview.studiosLabel.text = AnimeDetailFunc.getMainStudio(from: animeDetailData.studios)
        overview.producersLabel.text = AnimeDetailFunc.getProducers(from: animeDetailData.studios)
        overview.sourceLabel.text = animeDetailData.source
        overview.hashTagLabel.text = animeDetailData.hashtag
        overview.genresLabel.text = animeDetailData.genres.joined(separator: ",")
        overview.romajiLabel.text = animeDetailData.title.romaji
        overview.englishLabel.text = animeDetailData.title.english
        overview.nativeLabel.text = animeDetailData.title.native
        overview.synonymsLabel.text = animeDetailData.synonyms.joined(separator: ",")
        overview.informationScrollView.layer.cornerRadius = 10
        overview.informationScrollView.clipsToBounds = true
    }
    
    func setupAnimeDescription(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        overview.descriptionContextLabel.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: animeDetailData.description)
        overview.layer.cornerRadius = 10
        overview.descriptionContextLabel.clipsToBounds = true
    }
    
    func setupAnimeRelation(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        if let relations = animeDetailData.relations {
            for edge in relations.edges {
                let relationPreview = RelationPreview(frame: .zero, mediaID: edge.node.id)
                // 230:328 -> 115:164
                relationPreview.previewImage.kf.setImage(with: URL(string: edge.node.coverImage.large))
                relationPreview.sourceLabel.text = edge.relationType
                relationPreview.titleLabel.text = edge.node.title.userPreferred
                relationPreview.typeLabel.text = edge.node.type
                relationPreview.statusLabel.text = edge.node.status
                relationPreview.layer.cornerRadius = 10
                relationPreview.clipsToBounds = true
                
                relationPreview.snp.makeConstraints { make in
                    make.width.equalTo(UIScreen.main.bounds.width - 10)
                    make.height.equalTo(relationPreview.snp.width).multipliedBy(0.45)
                }
                overview.relationHStackView.addArrangedSubview(relationPreview)
            }
        }
    }
    
    func setupAnimeCharacter(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let characters = animeDetailData.characterPreview.edges
        for edge in characters {
            let characterPreview = CharacterPreview(frame: .zero, characterID: edge.node.id, voiceActorID: edge.voiceActors.first?.id ?? nil)
            characterPreview.characterIdPassDelegate = self
            characterPreview.voiceActorIdPassDelegate = self
            characterPreview.characterImageView.kf.setImage(with: URL(string: edge.node.image.large))
            characterPreview.characterNameLabel.text = edge.node.name.userPreferred
            characterPreview.characterRoleLabel.text = edge.role
            characterPreview.voiceActorImageView.kf.setImage(with: URL(string: edge.voiceActors.first?.image.large ?? "photo"))
            characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
            characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
            characterPreview.layer.cornerRadius = 10
            characterPreview.clipsToBounds = true
            
            characterPreview.snp.makeConstraints { make in
                make.height.equalTo(characterPreview.snp.width).multipliedBy(0.25)
            }
            overview.charactersVStackView.addArrangedSubview(characterPreview)
        }
    }
    
    func setupAnimeStaff(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let staffs = animeDetailData.staffPreview.edges
        for edge in staffs {
            let staffPreview = StaffPreview(frame: .zero, staffID: edge.node.id)
            staffPreview.staffImageView.kf.setImage(with: URL(string: edge.node.image.large))
            staffPreview.staffNameLabel.text = edge.node.name.userPreferred
            staffPreview.staffRoleLabel.text = edge.role
            staffPreview.layer.cornerRadius = 10
            staffPreview.clipsToBounds = true
            
            overview.staffsVStackView.addArrangedSubview(staffPreview)
            staffPreview.snp.makeConstraints { make in
                make.height.equalTo(staffPreview.snp.width).multipliedBy(0.25)
            }
        }
    }
    
    func setupAnimeStatusDistribution(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let animeDetailData = animeDetailData
        let statusDistribution = animeDetailData.stats.statusDistribution.sorted(by: {$0.amount > $1.amount})
        let totalAmount = statusDistribution.reduce(0) { (result, statusDistribution) -> Int in
            return result + statusDistribution.amount
        }
        let statusDistributionAmountLabel = [overview.statusDistributionFirstLabel, overview.statusDistributionSecondLabel, overview.statusDistributionThirdLabel, overview.statusDistributionFourthLabel, overview.statusDistributionFifthLabel]
        let statusDistributionStatusLabel = [overview.statusDistributionFirst, overview.statusDistributionSecond, overview.statusDistributionThird, overview.statusDistributionFourth, overview.statusDistributionFifth]
        let statsColor: [UIColor] = [#colorLiteral(red: 0.4110881686, green: 0.8372716904, blue: 0.2253350019, alpha: 1), #colorLiteral(red: 0.00486722542, green: 0.6609873176, blue: 0.9997979999, alpha: 1), #colorLiteral(red: 0.5738196373, green: 0.3378910422, blue: 0.9544720054, alpha: 1), #colorLiteral(red: 0.9687278867, green: 0.4746391773, blue: 0.6418368816, alpha: 1), #colorLiteral(red: 0.9119635224, green: 0.3648597598, blue: 0.4597702026, alpha: 1)]
        var buttonConf = UIButton.Configuration.filled()
        buttonConf.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        for (index, label) in statusDistributionStatusLabel.enumerated() {
            buttonConf.baseBackgroundColor = statsColor[index]
            buttonConf.baseForegroundColor = .white
            buttonConf.title = statusDistribution[index].status.uppercased()
            label?.configuration = buttonConf
        }
        for (index, label) in statusDistributionAmountLabel.enumerated() {
            label?.text = "\(statusDistribution[index].amount)"
            label?.adjustsFontSizeToFitWidth = true
        }
        var lastView: UIView? = nil
        for (index, status) in statusDistribution.enumerated() {
            let tmpView = UIView()
            tmpView.backgroundColor = statsColor[index]
            overview.statusDistributionPercentView.addSubview(tmpView)
            
            let ratio = CGFloat(status.amount) / CGFloat(totalAmount)
            
            tmpView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(overview.statusDistributionPercentView.snp.width).multipliedBy(ratio)
                
                if let lastView = lastView {
                    make.leading.equalTo(lastView.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                
                if index == statusDistribution.count - 1 {
                    make.trailing.equalToSuperview() // 避免總寬加總不準
                }
            }
            
            lastView = tmpView
        }
    }
    
    func setupAnimeScoreDistriubtionView(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let scoreAmountTotal = animeDetailData.stats.scoreDistribution.reduce(0) { ( result, scoreDistribution) -> Int in
            return result + scoreDistribution.amount
        }
        let scoreDistribution = animeDetailData.stats.scoreDistribution
        for (index, score) in scoreDistribution.enumerated() {
            let percent = AnimeDetailFunc.partOfAmount(value: score.amount, totalValue: scoreAmountTotal)
            let scoreView = UIView() // 顏色條
            scoreView.layer.cornerRadius = 5
            scoreView.clipsToBounds = true
            // 0 1 2 3 4(yellow) | 5 6 7 8 9
            if index < 5 {
                scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemRed, color2: UIColor.systemYellow, fraction: CGFloat(index) / 5)
            } else {
                scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemYellow, color2: UIColor.systemGreen, fraction: CGFloat(index - 4) / 5)
            }
            let scoreDistributionContainer = UIView() // 裝顏色條 分數標籤 百分比的容器
            scoreDistributionContainer.addSubview(scoreView)
            scoreView.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-40)
                make.height.equalTo(UIScreen.main.bounds.height * 0.1 * percent + 10)
                make.width.equalTo(25)
                make.centerX.equalToSuperview()
            }
            
            let percentLabel = UILabel()
            percentLabel.adjustsFontSizeToFitWidth = true
            percentLabel.text = String(format: "%.1f%%", percent * 100)
            scoreDistributionContainer.addSubview(percentLabel)
            percentLabel.snp.makeConstraints { make in
                make.bottom.equalTo(scoreView.snp.top).offset(-10)
                make.width.equalTo(30)
                make.centerX.equalToSuperview()
            }
            
            let scoreLabel = UILabel()
            scoreLabel.textAlignment = .center
            scoreLabel.text = "\(score.score)"
            scoreLabel.textColor = .secondaryLabel
            scoreDistributionContainer.addSubview(scoreLabel)
            scoreLabel.snp.makeConstraints { make in
                make.top.equalTo(scoreView.snp.bottom).offset(5)
                make.width.equalTo(30)
                make.centerX.equalToSuperview()
            }
            
            scoreDistributionContainer.snp.makeConstraints { make in
                make.width.equalTo(30)
            }
            overview.scoreDistributionHStack.addArrangedSubview(scoreDistributionContainer)
        }
    }
    
    func setupAnimeWatchHStack(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let streamingEpisodes = animeDetailData.streamingEpisodes
        guard !streamingEpisodes.isEmpty else {
            let voidLabel = UILabel()
            voidLabel.backgroundColor = .white
            voidLabel.text = "This anime didn't have any source provided by the AniList API."
            voidLabel.textAlignment = .center
            voidLabel.numberOfLines = 0
            voidLabel.font = .italicSystemFont(ofSize: 15)
            voidLabel.textColor = UIColor.secondaryLabel
            voidLabel.layer.cornerRadius = 10
            voidLabel.clipsToBounds = true
            overview.watchHStack.addArrangedSubview(voidLabel)
            voidLabel.snp.makeConstraints { make in
                make.width.equalTo(UIScreen.main.bounds.width - 10)
            }
            return
        }
        for streaming in streamingEpisodes {
            let watchPreview = AnimeWatchPreview(frame: .zero, site: streaming.site, url: streaming.url)
//                watchPreview.openUrlDelegate = self
            watchPreview.animeWatchPreviewImageView.kf.setImage(with: URL(string: streaming.thumbnail))
            watchPreview.animeWatchPreviewLabel.text = streaming.title
            
            watchPreview.layer.cornerRadius = 10
            watchPreview.clipsToBounds = true
            
            overview.watchHStack.addArrangedSubview(watchPreview)
            watchPreview.snp.makeConstraints { make in
                make.height.equalTo(UIScreen.main.bounds.width * 0.33)
                make.width.equalTo(watchPreview.snp.height).multipliedBy(2)
            }
        }
    }
    
    func setupAnimeRecommendationsHStack(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let recommendations = animeDetailData.recommendations.nodes
        for recommendation in recommendations {
            let recommendationsPreview = RecommendationsAnimePreview(frame: .zero, animeID: recommendation.mediaRecommendation?.id)
            
            recommendationsPreview.recommendationDelegate = self
            
            recommendationsPreview.animeTitle.text = recommendation.mediaRecommendation?.title.userPreferred
            if let coverImage = recommendation.mediaRecommendation?.coverImage?.large {
                recommendationsPreview.coverImageView.kf.setImage(with: URL(string: coverImage))
            }
            overview.recommendationsHStack.addArrangedSubview(recommendationsPreview)
            
            recommendationsPreview.snp.makeConstraints { make in
                make.width.equalTo(UIScreen.main.bounds.width * 0.33)
            }
        }
        
        
    }
    
    func setupAnimeReviewsVStack(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let reviews = animeDetailData.reviewPreview.nodes
        if reviews.count == 0 {
            let voidLabel = UILabel()
            voidLabel.backgroundColor = .white
            voidLabel.text = "\t\tThis anime didn't have review yet"
            voidLabel.font = .italicSystemFont(ofSize: 15)
            voidLabel.textColor = UIColor.secondaryLabel
            voidLabel.layer.cornerRadius = 10
            voidLabel.clipsToBounds = true
            overview.reviewsVStack.addArrangedSubview(voidLabel)
            voidLabel.snp.makeConstraints { make in
                make.height.equalTo(60)
            }
        } else {
            for review in reviews {
                let animeReview = AnimeReview()
                animeReview.userReviewLabel.layer.cornerRadius = 10
                animeReview.userReviewLabel.clipsToBounds = true
                animeReview.userAvatar.kf.setImage(with: URL(string: review.user.avatar?.large ?? ""))
                animeReview.userReviewLabel.text = review.summary
                overview.reviewsVStack.addArrangedSubview(animeReview)
            }
        }
    }
    
    func setupAnimeExternalLinkVStack(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let externalLinks = animeDetailData.externalLinks
        for externalLink in externalLinks {
            let externalLinkPreview = ExternalLinkPreview(frame: .zero, url: externalLink.url, siteName: externalLink.site)
//                externalLinkPreview.openURLDelegate = self
            if let externalLinkIcon = externalLink.icon {
                externalLinkPreview.externalLinkIcon.kf.setImage(with: URL(string: externalLinkIcon))
            } else {
                externalLinkPreview.externalLinkIcon.image = UIImage(systemName: "link")
            }
            externalLinkPreview.externalLinkIcon.backgroundColor = UIColor(hex: externalLink.color)
            externalLinkPreview.externalLinkIconColor.backgroundColor = UIColor(hex: externalLink.color)
            externalLinkPreview.externalLinkIconColor.layer.cornerRadius = 10
            externalLinkPreview.externalLinkIconColor.clipsToBounds = true
            externalLinkPreview.externalLinkTitle.text = externalLink.site
            
            externalLinkPreview.externalLinkTitleNote.text = externalLink.notes == nil ? "" : "(\(externalLink.notes!))"
            externalLinkPreview.externalLinkTitleNote.textColor = .secondaryLabel
            externalLinkPreview.layer.cornerRadius = 10
            externalLinkPreview.clipsToBounds = true
            overview.linkVStack.addArrangedSubview(externalLinkPreview)
        }
    }
    
    func setupAnimeTagsVStack(overview: Overview, animeDetailData: MediaResponse.MediaData.Media) {
        let tags = animeDetailData.tags
        for tag in tags {
            let tagPreview = TagPreview()
            tagPreview.tagName.text = tag.name
            tagPreview.tagPercent.text = "\(tag.rank) %"
            tagPreview.layer.cornerRadius = 10
            tagPreview.clipsToBounds = true
            
//            tagPreview.isHidden = tag.isMediaSpoiler
            overview.tagsVStack.addArrangedSubview(tagPreview)
            
            tagPreview.snp.makeConstraints { make in
                make.height.equalTo(40)
            }
            
            if tag.isMediaSpoiler {
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                tagPreview.addSubview(blurEffectView)
                blurEffectView.snp.makeConstraints { make in
                    make.leading.trailing.top.bottom.equalToSuperview()
                }
                let eyeSlashImg = UIImageView(image: UIImage(systemName: "eye.slash.fill"))
                eyeSlashImg.tintColor = .secondaryLabel
//                eyeSlashImg.translatesAutoresizingMaskIntoConstraints = false
//                blurEffectView.contentView.addSubview(eyeSlashImg)
                let spoilerText = UILabel()
                spoilerText.text = "Spoiler Tag"
                spoilerText.textColor = .secondaryLabel
                spoilerText.font = UIFont.boldSystemFont(ofSize: 14)
                let spoilerTemplateView = UIStackView(arrangedSubviews: [eyeSlashImg, spoilerText])
                spoilerTemplateView.axis = .horizontal
                spoilerTemplateView.spacing = 10
                blurEffectView.contentView.addSubview(spoilerTemplateView)
                spoilerTemplateView.snp.makeConstraints { make in
                    make.centerX.centerY.equalTo(blurEffectView.contentView)
                }
                
                let tapToShow = UITapGestureRecognizer(target: self, action: #selector(showSpoiler))
                blurEffectView.addGestureRecognizer(tapToShow)
            }
        }
    }
    // MARK: - Watch
    func setupWatch(streamingEpisodes: [MediaResponse.MediaData.Media.StreamingEpisodes]) {
        print(streamingEpisodes)
        let animeWatchView = AnimeWatchView()
        container.addSubview(animeWatchView)
        animeWatchView.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalToSuperview()
        }
        let streamingEpisodes = streamingEpisodes
        for streaming in streamingEpisodes {
            let watchPreview = AnimeWatchPreview(frame: .zero, site: streaming.site, url: streaming.url)
//            watchPreview.openUrlDelegate = self
//            watchPreview.animeWatchPreviewImageView.loadImage(from: streaming.thumbnail)
            watchPreview.animeWatchPreviewImageView.kf.setImage(with: URL(string: streaming.thumbnail))
            watchPreview.animeWatchPreviewLabel.text = streaming.title
            animeWatchView.watchVStack.addArrangedSubview(watchPreview)
            watchPreview.snp.makeConstraints { make in
                make.height.equalTo(watchPreview.snp.width).multipliedBy(0.5)
            }
        }
    }
    // MARK: - Characters
    func setupCharacters(characters: [MediaResponse.MediaData.Media.CharacterPreview.Edges]) {
        let animeCharactersView = AnimeCharactersView()
        container.addSubview(animeCharactersView)
        animeCharactersView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        let characters = characters
        for edge in characters {
            let characterPreview = CharacterPreview(frame: .zero, characterID: edge.node.id, voiceActorID: edge.voiceActors.first?.id ?? nil)
            
            characterPreview.characterIdPassDelegate = self
            characterPreview.voiceActorIdPassDelegate = self
            
            characterPreview.characterImageView.kf.setImage(with: URL(string: edge.node.image.large))
            characterPreview.characterNameLabel.text = edge.node.name.userPreferred
            characterPreview.characterRoleLabel.text = edge.role
            characterPreview.voiceActorImageView.kf.setImage(with: URL(string: edge.voiceActors.first?.image.large ?? ""))
            characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
            characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
            
            // image size width:height = 46:69
            characterPreview.snp.makeConstraints { make in
                make.height.equalTo(characterPreview.snp.width).multipliedBy(0.25)
            }
            animeCharactersView.charactersVStack.addArrangedSubview(characterPreview)
        }
    }
    
    func updateCharacters(container: AnimeCharactersView, edges: [MediaResponse.MediaData.Media.CharacterPreview.Edges]) {
        
        for edge in edges {
            let characterPreview = CharacterPreview(frame: .zero, characterID: edge.node.id, voiceActorID: edge.voiceActors.first?.id ?? nil)
            
            characterPreview.characterIdPassDelegate = self
            characterPreview.voiceActorIdPassDelegate = self
            
            characterPreview.characterImageView.loadImage(from: edge.node.image.large)
            characterPreview.characterNameLabel.text = edge.node.name.userPreferred
            characterPreview.characterRoleLabel.text = edge.role
            characterPreview.voiceActorImageView.kf.setImage(with: URL(string: edge.voiceActors.first?.image.large ?? ""))
            characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
            characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
            
            characterPreview.snp.makeConstraints { make in
                make.height.equalTo(characterPreview.snp.width).multipliedBy(0.25)
            }
            container.charactersVStack.addArrangedSubview(characterPreview)
        }
        
    }
    // MARK: - Stats
    func setupStats(rankingData: MediaRanking.MediaData.Media, stats: MediaResponse.MediaData.Media.Stats) {
        let statsView = AnimeStatsView()
        
        let rankingData = rankingData
        for (_, rankingData) in rankingData.rankings.enumerated() {
            let rankingPreview = RankingPreview()
            rankingPreview.rankingImageView.image = UIImage(systemName: ((rankingData.type == "RATED") ? "star.fill" : "heart.fill"))
            rankingPreview.rankingImageView.tintColor = rankingData.type == "RATED" ? UIColor.systemYellow : UIColor.systemRed
            rankingPreview.rankingTitleLabel.text = "#\(rankingData.rank) \(rankingData.year == nil ? "" : String(rankingData.year!)) \(rankingData.season == nil ? "" : rankingData.season!) \(rankingData.context.capitalized)"
            statsView.rankingsVStack.addArrangedSubview(rankingPreview)
            rankingPreview.snp.makeConstraints { make in
                make.height.equalTo(rankingPreview.snp.width).multipliedBy(0.25)
            }
        }
        // status distribution
        let statusDistribution = stats.statusDistribution.sorted(by: {$0.amount > $1.amount})
        let totalAmount = statusDistribution.reduce(0) { (result, statusDistribution) -> Int in
            return result + statusDistribution.amount
        }
        let statusDistributionAmountLabel = [statsView.statusDistributionFirstLabel, statsView.statusDistributionSecondLabel, statsView.statusDistributionThirdLabel, statsView.statusDistributionFourthLabel, statsView.statusDistributionFifthLabel]
        let statusDistributionStatusLabel = [statsView.statusDistributionFirst, statsView.statusDistributionSecond, statsView.statusDistributionThird, statsView.statusDistributionFourth, statsView.statusDistributionFifth]
        let statsColor: [UIColor] = [#colorLiteral(red: 0.4110881686, green: 0.8372716904, blue: 0.2253350019, alpha: 1), #colorLiteral(red: 0.00486722542, green: 0.6609873176, blue: 0.9997979999, alpha: 1), #colorLiteral(red: 0.5738196373, green: 0.3378910422, blue: 0.9544720054, alpha: 1), #colorLiteral(red: 0.9687278867, green: 0.4746391773, blue: 0.6418368816, alpha: 1), #colorLiteral(red: 0.9119635224, green: 0.3648597598, blue: 0.4597702026, alpha: 1)]
        var buttonConf = UIButton.Configuration.filled()
        buttonConf.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        for (index, label) in statusDistributionStatusLabel.enumerated() {
            buttonConf.baseBackgroundColor = statsColor[index]
            buttonConf.baseForegroundColor = .white
            buttonConf.title = statusDistribution[index].status.uppercased()
            label?.configuration = buttonConf
        }
        for (index, label) in statusDistributionAmountLabel.enumerated() {
            label?.text = "\(statusDistribution[index].amount)"
            label?.adjustsFontSizeToFitWidth = true
        }
        var lastView: UIView = statsView.statusDistributionPercentView
        for (index, status) in statusDistribution.enumerated() {
            let tmpView = UIView()
            tmpView.backgroundColor = statsColor[index]
            tmpView.translatesAutoresizingMaskIntoConstraints = false
            statsView.statusDistributionPercentView.addSubview(tmpView)
            tmpView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            tmpView.bottomAnchor.constraint(equalTo: statsView.statusDistributionPercentView.bottomAnchor).isActive = true
            //            print(CGFloat(status.amount) / CGFloat(totalAmount) * statusDistributionView.persentView.bounds.size.width)
            if index != statusDistribution.count - 1 && index != 0 {
                
                tmpView.widthAnchor.constraint(equalTo: statsView.statusDistributionPercentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmount)).isActive = true
                tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
            } else if index == 0 {
                tmpView.leadingAnchor.constraint(equalTo: lastView.leadingAnchor).isActive = true
                tmpView.widthAnchor.constraint(equalTo: statsView.statusDistributionPercentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmount)).isActive = true
            } else {
                tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                tmpView.trailingAnchor.constraint(equalTo: statsView.statusDistributionPercentView.trailingAnchor).isActive = true
            }
            lastView = tmpView
        }
        
        // score distribution
        let scoreAmountTotal = stats.scoreDistribution.reduce(0) { ( result, scoreDistribution) -> Int in
            return result + scoreDistribution.amount
        }
        if let scoreDistribution = viewModel?.animeDetailData?.stats.scoreDistribution {
            for (index, score) in scoreDistribution.enumerated() {
                let percent = AnimeDetailFunc.partOfAmount(value: score.amount, totalValue: scoreAmountTotal)
                let scoreView = UIView()
                scoreView.layer.cornerRadius = 5
                scoreView.clipsToBounds = true
                // 0 1 2 3 4(yellow) | 5 6 7 8 9
                if index < 5 {
                    scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemRed, color2: UIColor.systemYellow, fraction: CGFloat(index) / 5)
                } else {
                    scoreView.backgroundColor = AnimeDetailFunc.mixColor(color1: UIColor.systemYellow, color2: UIColor.systemGreen, fraction: CGFloat(index - 4) / 5)
                }
                let scoreDistributionContainer = UIView()
                scoreDistributionContainer.addSubview(scoreView)
                scoreView.translatesAutoresizingMaskIntoConstraints = false
                scoreView.bottomAnchor.constraint(equalTo: scoreDistributionContainer.bottomAnchor, constant: -40).isActive = true
                scoreView.heightAnchor.constraint(equalToConstant: 100 * percent + 10).isActive = true
                scoreView.widthAnchor.constraint(equalToConstant: 25).isActive = true
                scoreView.centerXAnchor.constraint(equalTo: scoreDistributionContainer.centerXAnchor).isActive = true
                
                let percentLabel = UILabel()
                percentLabel.adjustsFontSizeToFitWidth = true
                percentLabel.translatesAutoresizingMaskIntoConstraints = false
                percentLabel.text = String(format: "%.1f%%", percent * 100)
                scoreDistributionContainer.addSubview(percentLabel)
                percentLabel.bottomAnchor.constraint(equalTo: scoreView.topAnchor, constant: -10).isActive = true
                percentLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
                percentLabel.centerXAnchor.constraint(equalTo: scoreDistributionContainer.centerXAnchor).isActive = true
                
                let scoreLabel = UILabel()
                scoreLabel.translatesAutoresizingMaskIntoConstraints = false
                scoreLabel.textAlignment = .center
                scoreLabel.text = "\(score.score)"
                scoreLabel.textColor = .secondaryLabel
                scoreDistributionContainer.addSubview(scoreLabel)
                scoreLabel.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 5).isActive = true
                scoreLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
                scoreLabel.centerXAnchor.constraint(equalTo: scoreDistributionContainer.centerXAnchor).isActive = true
                scoreDistributionContainer.widthAnchor.constraint(equalToConstant: 30).isActive = true
                statsView.scoreDistributionHStack.addArrangedSubview(scoreDistributionContainer)
            }
        }
        container.addSubview(statsView)
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        statsView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        statsView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        statsView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
    }
    // MARK: - Social
    func setupSocial() {
        
    }
    // MARK: - Staff
    func setupStaff(staffData: [MediaResponse.MediaData.Media.StaffPreview.Edges]) {
        let staffView = AnimeStaffView()
        container.addSubview(staffView)
        staffView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        let animeStaffData = staffData
        for (_, edge) in animeStaffData.enumerated() {
            let staffPreview = StaffPreview(frame: .zero, staffID: edge.node.id)
            
            staffPreview.staffIdDelegate = self
            
            staffPreview.staffImageView.kf.setImage(with: URL(string: edge.node.image.large))
            staffPreview.staffNameLabel.text = edge.node.name.userPreferred
            staffPreview.staffRoleLabel.text = edge.role
            staffView.staffVStack.addArrangedSubview(staffPreview)
            staffPreview.snp.makeConstraints { make in
                make.height.equalTo(staffPreview.snp.width).multipliedBy(0.25)
            }
        }
    }
    
    func updateStaffs(container: AnimeStaffView, edges: [MediaResponse.MediaData.Media.StaffPreview.Edges]) {
        let edges = edges
        for (_, edge) in edges.enumerated() {
            let staffPreview = StaffPreview(frame: .zero, staffID: edge.node.id)
            
            staffPreview.staffIdDelegate = self
            
            staffPreview.staffImageView.kf.setImage(with: URL(string: edge.node.image.large))
            staffPreview.staffNameLabel.text = edge.node.name.userPreferred
            staffPreview.staffRoleLabel.text = edge.role
            container.staffVStack.addArrangedSubview(staffPreview)
            staffPreview.snp.makeConstraints { make in
                make.height.equalTo(staffPreview.snp.width).multipliedBy(0.25)
            }
        }
    }
    
    // MARK: - Favorite and Notification button
    func updateFunctionalButton(isOnColor: UIColor, for button: UIButton, isOn: Bool) {
        button.tintColor = isOn ? isOnColor : .gray.withAlphaComponent(0.5)
    }
}

extension AnimeDetailPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == wholePageScrollView {
            contentSwitchBtnScrollView.alpha = 0.5
        }
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if let _ = container.subviews.first as? AnimeCharactersView {
            if offsetY > contentHeight - frameHeight && AnimeDataFetcher.shared.isFetchingData == false {
                viewModel?.shouldLoadMoreCharacters.send(())
            }
        } else if let _ = container.subviews.first as? AnimeStaffView {
            if offsetY > contentHeight - frameHeight && AnimeDataFetcher.shared.isFetchingData == false {
                viewModel?.shouldLoadMoreStaffs.send(())
            }
        }
        
        if scrollView == wholePageScrollView {
            guard let navigationController = navigationController else { return }
            if (contentSwitchBtnScrollView.frame.minY > navigationController.navigationBar.frame.maxY + 10 + scrollView.contentOffset.y) && isNavigationBarHidden == false {
                UIView.animate(withDuration: 0.5) {
                    self.contentSwitchBtnScrollView.transform = .identity
                }
            } else {
                if isNavigationBarHidden == false {
                    UIView.animate(withDuration: 0.5) {
                        self.contentSwitchBtnScrollView.transform = CGAffineTransform(translationX: 50, y: 0)
                    }
                }
            }
            let threshold: CGFloat = 10
            if offsetY > wholePageScrollViewContentOffsetY + threshold && !isNavigationBarHidden {
                isNavigationBarHidden = true
                navigationController.setNavigationBarHidden(true, animated: true)
                UIView.animate(withDuration: 0.5) {
                    self.contentSwitchBtnScrollView.transform = .identity
                }
            } else if offsetY < wholePageScrollViewContentOffsetY - threshold && isNavigationBarHidden {
                isNavigationBarHidden = false
                navigationController.setNavigationBarHidden(false, animated: true)
            }
            wholePageScrollViewContentOffsetY = offsetY
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentSwitchBtnScrollView.alpha = 1.0
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        contentSwitchBtnScrollView.alpha = 1.0
    }
}

extension AnimeDetailPageViewController: CharacterIdDelegate {
    func showCharacterPage(characterId: Int) {
        let vc = UIStoryboard(name: "AnimeCharacterPage", bundle: nil).instantiateViewController(identifier: "AnimeCharacterPage") as! AnimeCharacterPageViewController
        vc.viewModel = AnimeCharacterPageViewModel(characterID: characterId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AnimeDetailPageViewController: VoiceActorIdDelegate {
    func showVoiceActorPage(voiceActorId: Int) {
        let vc = UIStoryboard(name: "AnimeVoiceActorPage", bundle: nil).instantiateViewController(withIdentifier: "VoiceActorPage") as! AnimeVoiceActorViewController
        vc.viewModel = AnimeVoiceActorPageViewModel(voiceActorID: voiceActorId)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AnimeDetailPageViewController: StaffIdDelegate {
    func showStaffPage(staffID: Int) {
        let vc = UIStoryboard(name: "StaffDetailView", bundle: nil).instantiateViewController(withIdentifier: "StaffDetailView") as! StaffDetailViewController
        vc.viewModel = StaffDetailViewModel(staffId: staffID)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AnimeDetailPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension AnimeDetailPageViewController: RecommendationDelegate {
    func passRecommendationAnimeID(_ id: Int) {
        let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(identifier: "AnimeDetailView") as! AnimeDetailPageViewController
        vc.viewModel = AnimeDetailPageViewModel(animeID: id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
