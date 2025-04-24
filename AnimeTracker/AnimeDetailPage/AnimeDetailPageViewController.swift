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
    @IBOutlet weak var showOverViewBtn: UIButton!
    @IBOutlet weak var showWatchBtn: UIButton!
    @IBOutlet weak var showCharactersBtn: UIButton!
    @IBOutlet weak var showStatsBtn: UIButton!
    @IBOutlet weak var showSocialBtn: UIButton!
    @IBOutlet weak var showStaffBtn: UIButton!
    @IBOutlet weak var container: UIView!
    
    var viewModel: AnimeDetailPageViewModel?
    private var cancellables: Set<AnyCancellable> = []
    
    let loadMoreStaffDataTrigger: PassthroughSubject<Void, Never> = .init()
    
    weak var fastNavigate: NavigateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationController?.hidesBarsOnSwipe = true
        
        
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurrEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//        blurrEffectView.contentView.addSubview(vibrancyEffectView)

        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeGesture.direction = .right
        swipeGesture.delegate = self
        self.view.addGestureRecognizer(swipeGesture)
        
        let backButton = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(swipeAction))
        backButton.image = UIImage(systemName: "chevron.backward")
        navigationItem.leftBarButtonItem = backButton
        
        viewModel?.$animeDetailData
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { _ in
                self.setupBaseView()
                self.showContent(self.showOverViewBtn)
            })
            .store(in: &cancellables)
        
        viewModel?.$newAnimeCharacterData
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { edges in
                if let container = self.container.subviews.first as? AnimeCharactersView {
                    self.updateCharacters(container: container, edges: edges)
                }
            })
            .store(in: &cancellables)
        
        viewModel?.subscribeLoadMoreStaffDataTrigger(trigger: loadMoreStaffDataTrigger.eraseToAnyPublisher())
        
        viewModel?.newAnimeStaffDataPassThrough
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { edges in
                if let container = self.container.subviews.first as? AnimeStaffView {
                    self.updateStaffs(container: container, edges: edges)
                }
            })
            .store(in: &cancellables)
        
        wholePageScrollView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FloatingButtonManager.shared.addToView(toView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func showContent(_ sender: UIButton) {
        configureButtonsColor(sender: sender, buttonArr: [showOverViewBtn, showStaffBtn, showCharactersBtn, showWatchBtn, showSocialBtn, showStatsBtn])
        for subview in container.subviews {
            subview.removeFromSuperview()
        }
        switch sender {
            case showOverViewBtn:
                setupOverview()
            case showWatchBtn:
                setupWatch()
            case showCharactersBtn:
                setupCharacters()
            case showStatsBtn:
                setupStats()
            case showSocialBtn:
                setupSocial()
            case showStaffBtn:
                setupStaff()
            default:
                break
        }
    }
    
    func setupBaseView() {
        backgroundImageView.kf.setImage(with: URL(string: viewModel?.animeDetailData?.coverImage.extraLarge ?? ""))
        animeBannerImage.kf.setImage(with: URL(string: viewModel?.animeDetailData?.bannerImage ?? (viewModel?.animeDetailData?.coverImage.extraLarge ?? "")))
        
        animeThumbnailImage.kf.setImage(with: URL(string: viewModel?.animeDetailData?.coverImage.extraLarge ?? ""))
        animeTitleLabel.text = viewModel?.animeDetailData?.title.native
    }
    
    func setupOverview() {
        let overview = Overview()
        overview.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(overview)
        overview.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        overview.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        overview.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        overview.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        setupAnimeInformation(overview: overview)
        setupAnimeDescription(overview: overview)
        setupAnimeRelation(overview: overview)
        setupAnimeCharacter(overview: overview)
        setupAnimeStaff(overview: overview)
        setupAnimeStatusDistribution(overview: overview)
        setupAnimeScoreDistriubtionView(overview: overview)
        setupAnimeWatchHStack(overview: overview)
        setupAnimeRecommendationsHStack(overview: overview)
        setupAnimeReviewsVStack(overview: overview)
        setupAnimeExternalLinkVStack(overview: overview)
        setupAnimeTagsVStack(overview: overview)
    }
    
    func setupWatch() {
        let animeWatchView = AnimeWatchView()
        animeWatchView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animeWatchView)
        animeWatchView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        animeWatchView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        animeWatchView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        animeWatchView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        if let streamingEpisodes = viewModel?.animeDetailData?.streamingEpisodes {
            for streaming in streamingEpisodes {
                let watchPreview = AnimeWatchPreview(frame: .zero, site: streaming.site, url: streaming.url)
//                watchPreview.openUrlDelegate = self
                watchPreview.animeWatchPreviewImageView.loadImage(from: streaming.thumbnail)
                watchPreview.animeWatchPreviewLabel.text = streaming.title
                watchPreview.translatesAutoresizingMaskIntoConstraints = false
                animeWatchView.watchVStack.addArrangedSubview(watchPreview)
                
//                watchPreview.heightAnchor.constraint(equalToConstant: 128).isActive = true
                watchPreview.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6).isActive = true
            }
        }
    }
    
    func setupCharacters() {
        let animeCharactersView = AnimeCharactersView()
        animeCharactersView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animeCharactersView)
        animeCharactersView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        animeCharactersView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        animeCharactersView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        animeCharactersView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        if let characters = viewModel?.animeCharacterData?.edges {
            for edge in characters {
                let characterPreview = CharacterPreview(frame: .zero, characterID: edge.node.id, voiceActorID: edge.voiceActors.first?.id ?? nil)
                characterPreview.characterIdPassDelegate = self
                characterPreview.voiceActorIdPassDelegate = self
                characterPreview.characterImageView.loadImage(from: edge.node.image.large)
                characterPreview.characterNameLabel.text = edge.node.name.userPreferred
                characterPreview.characterRoleLabel.text = edge.role
                characterPreview.voiceActorImageView.loadImage(from: edge.voiceActors.first?.image.large ?? "photo")
                characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
                characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
                
                characterPreview.translatesAutoresizingMaskIntoConstraints = false
                characterPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
                characterPreview.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10).isActive = true
                animeCharactersView.charactersVStack.addArrangedSubview(characterPreview)
            }
        }
    }
    
    func setupStats() {
        let statsView = AnimeStatsView()
        // ranking
        if viewModel?.animeRankingData == nil {
            viewModel?.loadAnimeRankingData()
        }
        viewModel?.$animeRankingData
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { _ in
                if let rankingDataNotNil = self.viewModel?.animeRankingData {
                    for (_, rankingData) in rankingDataNotNil.rankings.enumerated() {
                        let rankingPreview = RankingPreview()
                        rankingPreview.rankingImageView.image = UIImage(systemName: ((rankingData.type == "RATED") ? "star.fill" : "heart.fill"))
                        rankingPreview.rankingImageView.tintColor = rankingData.type == "RATED" ? UIColor.systemYellow : UIColor.systemRed
                        rankingPreview.rankingTitleLabel.text = "#\(rankingData.rank) \(rankingData.year == nil ? "" : String(rankingData.year!)) \(rankingData.season == nil ? "" : rankingData.season!) \(rankingData.context.capitalized)"
                        rankingPreview.translatesAutoresizingMaskIntoConstraints = false
                        statsView.rankingsVStack.addArrangedSubview(rankingPreview)
//                        rankingPreview.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10).isActive = true
                        rankingPreview.heightAnchor.constraint(equalToConstant: 40).isActive = true
                    }
                }
            })
            .store(in: &cancellables)
       
        
        // status distribution
        let statusDistribution = viewModel?.animeDetailData?.stats.statusDistribution.sorted(by: {$0.amount > $1.amount})
        let totalAmount = statusDistribution?.reduce(0) { (result, statusDistribution) -> Int in
            return result + statusDistribution.amount
        }
        let statusDistributionAmountLabel = [statsView.statusDistributionFirstLabel, statsView.statusDistributionSecondLabel, statsView.statusDistributionThirdLabel, statsView.statusDistributionFourthLabel, statsView.statusDistributionFifthLabel]
        let statusDistributionStatusLabel = [statsView.statusDistributionFirst, statsView.statusDistributionSecond, statsView.statusDistributionThird, statsView.statusDistributionFourth, statsView.statusDistributionFifth]
        let statsColor: [UIColor] = [#colorLiteral(red: 0.4110881686, green: 0.8372716904, blue: 0.2253350019, alpha: 1), #colorLiteral(red: 0.00486722542, green: 0.6609873176, blue: 0.9997979999, alpha: 1), #colorLiteral(red: 0.5738196373, green: 0.3378910422, blue: 0.9544720054, alpha: 1), #colorLiteral(red: 0.9687278867, green: 0.4746391773, blue: 0.6418368816, alpha: 1), #colorLiteral(red: 0.9119635224, green: 0.3648597598, blue: 0.4597702026, alpha: 1)]
        var buttonConf = UIButton.Configuration.filled()
        buttonConf.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        if let statusDistributionNotNil = statusDistribution, let totalAmountNotNil = totalAmount {
            for (index, label) in statusDistributionStatusLabel.enumerated() {
                buttonConf.baseBackgroundColor = statsColor[index]
                buttonConf.baseForegroundColor = .white
                buttonConf.title = statusDistribution?[index].status.uppercased()
                label?.configuration = buttonConf
            }
            for (index, label) in statusDistributionAmountLabel.enumerated() {
                label?.text = "\(statusDistributionNotNil[index].amount)"
                label?.adjustsFontSizeToFitWidth = true
            }
            var lastView: UIView = statsView.statusDistributionPercentView
            for (index, status) in statusDistributionNotNil.enumerated() {
                let tmpView = UIView()
                tmpView.backgroundColor = statsColor[index]
                tmpView.translatesAutoresizingMaskIntoConstraints = false
                statsView.statusDistributionPercentView.addSubview(tmpView)
                tmpView.heightAnchor.constraint(equalToConstant: 15).isActive = true
                tmpView.bottomAnchor.constraint(equalTo: statsView.statusDistributionPercentView.bottomAnchor).isActive = true
                //            print(CGFloat(status.amount) / CGFloat(totalAmount) * statusDistributionView.persentView.bounds.size.width)
                if index != statusDistributionNotNil.count - 1 && index != 0 {
                    
                    tmpView.widthAnchor.constraint(equalTo: statsView.statusDistributionPercentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmountNotNil)).isActive = true
                    tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                } else if index == 0 {
                    tmpView.leadingAnchor.constraint(equalTo: lastView.leadingAnchor).isActive = true
                    tmpView.widthAnchor.constraint(equalTo: statsView.statusDistributionPercentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmountNotNil)).isActive = true
                } else {
                    tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                    tmpView.trailingAnchor.constraint(equalTo: statsView.statusDistributionPercentView.trailingAnchor).isActive = true
                }
                lastView = tmpView
            }
        }
        // score distribution
        let scoreAmountTotal = viewModel?.animeDetailData?.stats.scoreDistribution.reduce(0) { ( result, scoreDistribution) -> Int in
            return result + scoreDistribution.amount
        }
        if let scoreDistribution = viewModel?.animeDetailData?.stats.scoreDistribution {
            for (index, score) in scoreDistribution.enumerated() {
                let percent = AnimeDetailFunc.partOfAmount(value: score.amount, totalValue: scoreAmountTotal ?? 0)
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
    
    func setupSocial() {
        
    }
    
    func setupStaff() {
        let staffView = AnimeStaffView()
        staffView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(staffView)
        staffView.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        staffView.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        staffView.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        staffView.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        guard let animeStaffData = viewModel?.animeStaffData else { return }
        for (_, edge) in animeStaffData.edges.enumerated() {
            let staffPreview = StaffPreview(frame: .zero, staffID: edge.node.id)
            staffPreview.staffIdDelegate = self
            staffPreview.staffImageView.loadImage(from: edge.node.image.large)
            staffPreview.staffNameLabel.text = edge.node.name.userPreferred
            staffPreview.staffRoleLabel.text = edge.role
            staffPreview.translatesAutoresizingMaskIntoConstraints = false
            staffView.staffVStack.addArrangedSubview(staffPreview)
            staffPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
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
            characterPreview.voiceActorImageView.loadImage(from: edge.voiceActors.first?.image.large ?? "photo")
            characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
            characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
            
            characterPreview.translatesAutoresizingMaskIntoConstraints = false
            characterPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
            characterPreview.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10).isActive = true
            container.charactersVStack.addArrangedSubview(characterPreview)
        }
        
    }
    
    func updateStaffs(container: AnimeStaffView, edges: [MediaResponse.MediaData.Media.StaffPreview.Edges]) {
        for (_, edge) in edges.enumerated() {
            let staffPreview = StaffPreview(frame: .zero, staffID: edge.node.id)
            staffPreview.staffIdDelegate = self
            staffPreview.staffImageView.loadImage(from: edge.node.image.large)
            staffPreview.staffNameLabel.text = edge.node.name.userPreferred
            staffPreview.staffRoleLabel.text = edge.role
            staffPreview.translatesAutoresizingMaskIntoConstraints = false
            container.staffVStack.addArrangedSubview(staffPreview)
            staffPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
        }
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
    
    func setupAnimeInformation(overview: Overview) {
        
        if let animeDetailData = viewModel?.animeDetailData {
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
        }
    }
    func setupAnimeDescription(overview: Overview) {
        overview.descriptionContextLabel.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: viewModel?.animeDetailData?.description ?? "")
    }
    func setupAnimeRelation(overview: Overview) {
        if let relations = viewModel?.animeDetailData?.relations {
            for edge in relations.edges {
                let relationPreview = RelationPreview(frame: .zero, mediaID: edge.node.id)
                relationPreview.previewImage.loadImage(from: edge.node.coverImage.large)
                relationPreview.sourceLabel.text = edge.relationType
                relationPreview.titleLabel.text = edge.node.title.userPreferred
                relationPreview.typeLabel.text = edge.node.type
                relationPreview.statusLabel.text = edge.node.status
                relationPreview.translatesAutoresizingMaskIntoConstraints = false
                relationPreview.widthAnchor.constraint(equalToConstant: 300).isActive = true
                overview.relationHStackView.addArrangedSubview(relationPreview)
            }
        }
    }
    func setupAnimeCharacter(overview: Overview) {
        if let characters = viewModel?.animeDetailData?.characterPreview.edges {
            for edge in characters {
                let characterPreview = CharacterPreview(frame: .zero, characterID: edge.node.id, voiceActorID: edge.voiceActors.first?.id ?? nil)
                characterPreview.characterIdPassDelegate = self
                characterPreview.voiceActorIdPassDelegate = self
                characterPreview.characterImageView.loadImage(from: edge.node.image.large)
                characterPreview.characterNameLabel.text = edge.node.name.userPreferred
                characterPreview.characterRoleLabel.text = edge.role
                characterPreview.voiceActorImageView.loadImage(from: edge.voiceActors.first?.image.large ?? "photo")
                characterPreview.voiceActorNameLabel.text = edge.voiceActors.first?.name.userPreferred
                characterPreview.voiceActorCountryLabel.text = edge.voiceActors.first?.language
                
                characterPreview.translatesAutoresizingMaskIntoConstraints = false
                characterPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
                characterPreview.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10).isActive = true
                overview.charactersVStackView.addArrangedSubview(characterPreview)
            }
        }
    }
    func setupAnimeStaff(overview: Overview) {
        if let staffs = viewModel?.animeDetailData?.staffPreview.edges {
            for edge in staffs {
                let staffPreview = StaffPreview(frame: .zero, staffID: edge.node.id)
                staffPreview.staffImageView.loadImage(from: edge.node.image.large)
                staffPreview.staffNameLabel.text = edge.node.name.userPreferred
                staffPreview.staffRoleLabel.text = edge.role
                staffPreview.translatesAutoresizingMaskIntoConstraints = false
                overview.staffsVStackView.addArrangedSubview(staffPreview)
                
                staffPreview.heightAnchor.constraint(equalToConstant: 83).isActive = true
                staffPreview.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 10).isActive = true
            }
        }
        
    }
    func setupAnimeStatusDistribution(overview: Overview) {
        let statusDistribution = viewModel?.animeDetailData?.stats.statusDistribution.sorted(by: {$0.amount > $1.amount})
        let totalAmount = statusDistribution?.reduce(0) { (result, statusDistribution) -> Int in
            return result + statusDistribution.amount
        }
        let statusDistributionAmountLabel = [overview.statusDistributionFirstLabel, overview.statusDistributionSecondLabel, overview.statusDistributionThirdLabel, overview.statusDistributionFourthLabel, overview.statusDistributionFifthLabel]
        let statusDistributionStatusLabel = [overview.statusDistributionFirst, overview.statusDistributionSecond, overview.statusDistributionThird, overview.statusDistributionFourth, overview.statusDistributionFifth]
        let statsColor: [UIColor] = [#colorLiteral(red: 0.4110881686, green: 0.8372716904, blue: 0.2253350019, alpha: 1), #colorLiteral(red: 0.00486722542, green: 0.6609873176, blue: 0.9997979999, alpha: 1), #colorLiteral(red: 0.5738196373, green: 0.3378910422, blue: 0.9544720054, alpha: 1), #colorLiteral(red: 0.9687278867, green: 0.4746391773, blue: 0.6418368816, alpha: 1), #colorLiteral(red: 0.9119635224, green: 0.3648597598, blue: 0.4597702026, alpha: 1)]
        var buttonConf = UIButton.Configuration.filled()
        buttonConf.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        if let statusDistributionNotNil = statusDistribution, let totalAmountNotNil = totalAmount {
            for (index, label) in statusDistributionStatusLabel.enumerated() {
                buttonConf.baseBackgroundColor = statsColor[index]
                buttonConf.baseForegroundColor = .white
                buttonConf.title = statusDistribution?[index].status.uppercased()
                label?.configuration = buttonConf
            }
            for (index, label) in statusDistributionAmountLabel.enumerated() {
                label?.text = "\(statusDistributionNotNil[index].amount)"
                label?.adjustsFontSizeToFitWidth = true
            }
            var lastView: UIView = overview.statusDistributionPercentView
            for (index, status) in statusDistributionNotNil.enumerated() {
                let tmpView = UIView()
                tmpView.backgroundColor = statsColor[index]
                tmpView.translatesAutoresizingMaskIntoConstraints = false
                overview.statusDistributionPercentView.addSubview(tmpView)
                tmpView.heightAnchor.constraint(equalToConstant: 15).isActive = true
                tmpView.bottomAnchor.constraint(equalTo: overview.statusDistributionPercentView.bottomAnchor).isActive = true
                //            print(CGFloat(status.amount) / CGFloat(totalAmount) * statusDistributionView.persentView.bounds.size.width)
                if index != statusDistributionNotNil.count - 1 && index != 0 {
                    
                    tmpView.widthAnchor.constraint(equalTo: overview.statusDistributionPercentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmountNotNil)).isActive = true
                    tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                } else if index == 0 {
                    tmpView.leadingAnchor.constraint(equalTo: lastView.leadingAnchor).isActive = true
                    tmpView.widthAnchor.constraint(equalTo: overview.statusDistributionPercentView.widthAnchor, multiplier: CGFloat(status.amount) / CGFloat(totalAmountNotNil)).isActive = true
                } else {
                    tmpView.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
                    tmpView.trailingAnchor.constraint(equalTo: overview.statusDistributionPercentView.trailingAnchor).isActive = true
                }
                lastView = tmpView
            }
        }
        
    }
    func setupAnimeScoreDistriubtionView(overview: Overview) {
        let scoreAmountTotal = viewModel?.animeDetailData?.stats.scoreDistribution.reduce(0) { ( result, scoreDistribution) -> Int in
            return result + scoreDistribution.amount
        }
        if let scoreDistribution = viewModel?.animeDetailData?.stats.scoreDistribution {
            for (index, score) in scoreDistribution.enumerated() {
                let percent = AnimeDetailFunc.partOfAmount(value: score.amount, totalValue: scoreAmountTotal ?? 0)
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
                
//                scoreDistributionContainer.heightAnchor.constraint(equalToConstant: 140).isActive = true
                scoreDistributionContainer.widthAnchor.constraint(equalToConstant: 30).isActive = true
                overview.scoreDistributionHStack.addArrangedSubview(scoreDistributionContainer)
            }
        }
        
    }
    func setupAnimeWatchHStack(overview: Overview) {
        if let streamingEpisodes = viewModel?.animeDetailData?.streamingEpisodes {
            for streaming in streamingEpisodes {
                let watchPreview = AnimeWatchPreview(frame: .zero, site: streaming.site, url: streaming.url)
//                watchPreview.openUrlDelegate = self
                watchPreview.animeWatchPreviewImageView.loadImage(from: streaming.thumbnail)
                watchPreview.animeWatchPreviewLabel.text = streaming.title
                watchPreview.translatesAutoresizingMaskIntoConstraints = false
                overview.watchHStack.addArrangedSubview(watchPreview)
                
//                watchPreview.heightAnchor.constraint(equalToConstant: 128).isActive = true
                watchPreview.widthAnchor.constraint(equalToConstant: 300).isActive = true
            }
        }
        
    }
    func setupAnimeRecommendationsHStack(overview: Overview) {
        if let recommendations = viewModel?.animeDetailData?.recommendations.nodes {
            for recommendation in recommendations {
                let recommendationsPreview = RecommendationsAnimePreview(frame: .zero, animeID: recommendation.mediaRecommendation?.id)
//                recommendationsPreview.animeDataFetcher = AnimeDataFetcher.shared.self
                recommendationsPreview.translatesAutoresizingMaskIntoConstraints = false
                recommendationsPreview.animeTitle.text = recommendation.mediaRecommendation?.title.userPreferred
                if let coverImage = recommendation.mediaRecommendation?.coverImage?.large {
                    recommendationsPreview.coverImageView.loadImage(from: coverImage)
                } else {
                    recommendationsPreview.coverImageView.image = UIImage(systemName: "photo")
                }
                overview.recommendationsHStack.addArrangedSubview(recommendationsPreview)
                
                recommendationsPreview.topAnchor.constraint(equalTo: recommendationsPreview.topAnchor).isActive = true
                recommendationsPreview.heightAnchor.constraint(equalTo: recommendationsPreview.heightAnchor).isActive = true
                recommendationsPreview.widthAnchor.constraint(equalToConstant: 100).isActive = true
            }
        }
        
    }
    func setupAnimeReviewsVStack(overview: Overview) {
        if let reviews = viewModel?.animeDetailData?.reviewPreview.nodes {
            if reviews.count == 0 {
                let voidLabel = UILabel()
                voidLabel.backgroundColor = .white
                voidLabel.text = "This anime didn't have review yet"
                voidLabel.font = .italicSystemFont(ofSize: 15)
                voidLabel.textColor = UIColor.secondaryLabel
                voidLabel.layer.cornerRadius = 10
                voidLabel.clipsToBounds = true
                voidLabel.translatesAutoresizingMaskIntoConstraints = false
                overview.reviewsVStack.addArrangedSubview(voidLabel)
                voidLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
                
            } else {
                for review in reviews {
                    let animeReview = AnimeReview()
                    animeReview.userReviewLabel.layer.cornerRadius = 10
                    animeReview.userReviewLabel.clipsToBounds = true
                    animeReview.userAvatar.loadImage(from: review.user.avatar?.large)
                    animeReview.userReviewLabel.text = review.summary
                    animeReview.translatesAutoresizingMaskIntoConstraints = false
                    overview.reviewsVStack.addArrangedSubview(animeReview)
                }
            }
        }
        
    }
    func setupAnimeExternalLinkVStack(overview: Overview) {
        if let externalLinks = viewModel?.animeDetailData?.externalLinks {
            for externalLink in externalLinks {
                let externalLinkPreview = ExternalLinkPreview(frame: .zero, url: externalLink.url, siteName: externalLink.site)
//                externalLinkPreview.openURLDelegate = self
                externalLinkPreview.translatesAutoresizingMaskIntoConstraints = false
                if let externalLinkIcon = externalLink.icon {
                    externalLinkPreview.externalLinkIcon.loadImage(from: externalLinkIcon)
                } else {
                    externalLinkPreview.externalLinkIcon.image = UIImage(systemName: "link")
                }
                externalLinkPreview.externalLinkIcon.backgroundColor = UIColor(hex: externalLink.color)
                externalLinkPreview.externalLinkIconColor.backgroundColor = UIColor(hex: externalLink.color)
                externalLinkPreview.externalLinkIconColor.layer.cornerRadius = 10
                externalLinkPreview.externalLinkIconColor.clipsToBounds = true
                externalLinkPreview.externalLinkTitle.text = externalLink.site
                //            externalLinkPreview.externalLinkTitle.textColor = .secondaryLabel
                externalLinkPreview.externalLinkTitleNote.text = externalLink.notes == nil ? "" : "(\(externalLink.notes!))"
                externalLinkPreview.externalLinkTitleNote.textColor = .secondaryLabel
                externalLinkPreview.layer.cornerRadius = 10
                externalLinkPreview.clipsToBounds = true
                overview.linkVStack.addArrangedSubview(externalLinkPreview)
            }
        }
        
    }
    func setupAnimeTagsVStack(overview: Overview) {
        if let tags = viewModel?.animeDetailData?.tags {
            for tag in tags {
                let tagPreview = TagPreview()
                tagPreview.tagName.text = tag.name
                tagPreview.tagPercent.text = "\(tag.rank) %"
                
    //            tagPreview.isHidden = tag.isMediaSpoiler
                tagPreview.translatesAutoresizingMaskIntoConstraints = false
                overview.tagsVStack.addArrangedSubview(tagPreview)
                
                tagPreview.heightAnchor.constraint(equalToConstant: 40).isActive = true
                
                if tag.isMediaSpoiler {
                    let blurEffect = UIBlurEffect(style: .light)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    print(tagPreview.bounds.size)
                    tagPreview.addSubview(blurEffectView)
                    blurEffectView.translatesAutoresizingMaskIntoConstraints = false
                    blurEffectView.leadingAnchor.constraint(equalTo: tagPreview.leadingAnchor).isActive = true
                    blurEffectView.trailingAnchor.constraint(equalTo: tagPreview.trailingAnchor).isActive = true
                    blurEffectView.heightAnchor.constraint(equalTo: tagPreview.heightAnchor).isActive = true
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
                    spoilerTemplateView.translatesAutoresizingMaskIntoConstraints = false
                    blurEffectView.contentView.addSubview(spoilerTemplateView)
                    spoilerTemplateView.centerXAnchor.constraint(equalTo: blurEffectView.centerXAnchor).isActive = true
                    spoilerTemplateView.centerYAnchor.constraint(equalTo: blurEffectView.centerYAnchor).isActive = true
                    
                    let tapToShow = UITapGestureRecognizer(target: self, action: #selector(showSpoiler))
                    blurEffectView.addGestureRecognizer(tapToShow)
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

extension AnimeDetailPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if Date.now.timeIntervalSince((viewModel?.lastFetchDataTime)!) > 2 {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            
            if let _ = container.subviews.first as? AnimeCharactersView {
                if offsetY > contentHeight - frameHeight && AnimeDataFetcher.shared.isFetchingData == false && viewModel?.animeCharacterData?.pageInfo.hasNextPage ?? false {
                    viewModel?.loadMoreCharactersData()
                }
            }
            
            if let _ = container.subviews.first as? AnimeStaffView {
                if offsetY > contentHeight - frameHeight && AnimeDataFetcher.shared.isFetchingData == false && viewModel?.animeStaffData?.pageInfo.hasNextPage ?? false {
                    loadMoreStaffDataTrigger.send()
                }
            }
            
        }
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
        return true
    }
}
