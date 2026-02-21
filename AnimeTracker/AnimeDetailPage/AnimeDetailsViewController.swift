//
//  AnimeDetailsViewController.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/2/14.
//

import UIKit
import SnapKit
import Kingfisher
import Combine

class AnimeDetailsViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.backgroundColor = .atBackground
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .atBackground
        return view
    }()
    
    lazy var animeBannerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var animeThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var animeTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .atTitle1
        label.textColor = .atTextPrimary
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var animeStatusScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    lazy var animeStatusHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        stackView.backgroundColor = .atSecondaryBackground
        stackView.layer.cornerRadius = 8
        stackView.clipsToBounds = true
        return stackView
    }()
    
    lazy var animeDetailsContainerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    private let vm: AnimeDetailPageViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    init(animeID: Int) {
        vm = .init(animeID: animeID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.forSelf {
            $0.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        scrollView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        containerView.addSubview(animeBannerImageView)
        animeBannerImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(animeBannerImageView.snp.width).multipliedBy(0.75)
        }
        
        containerView.addSubview(animeThumbnailImageView)
        animeThumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(animeBannerImageView.snp.bottom).offset(50)
            make.width.equalTo(150)
            make.height.equalTo(200)
        }
        
        containerView.addSubview(animeTitleLabel)
        animeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(animeThumbnailImageView.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(5)
        }
        
        containerView.addSubview(animeStatusScrollView)
        animeStatusScrollView.snp.makeConstraints { make in
            make.top.equalTo(animeTitleLabel.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(5)
        }
        
        animeStatusScrollView.addSubview(animeStatusHStackView)
        animeStatusHStackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(animeStatusScrollView.contentLayoutGuide)
            make.leading.trailing.equalTo(animeStatusScrollView.contentLayoutGuide).inset(5)
            make.height.equalTo(animeStatusScrollView.frameLayoutGuide)
        }
        
        containerView.addSubview(animeDetailsContainerStackView)
        animeDetailsContainerStackView.snp.makeConstraints { make in
            make.top.equalTo(animeStatusScrollView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(10)
        }
    }
    
    private func setupBinding() {
        vm.animeDetailPublisher
            .sink { [weak self] detail in
                self?.animeTitleLabel.text = detail.title
                self?.animeBannerImageView.kf.setImage(with: detail.animeBannerImageURL)
                self?.animeThumbnailImageView.kf.setImage(with: detail.animeThumbnailURL)
                self?.setupInformation(detail.basicInfomation)
                if let description = detail.animeDescription {
                    self?.setupAnimeDescription(description)
                }
                self?.setupAnimeRelations(detail.animeRelations)
                self?.setupAnimeCharacters(detail.animeCharacters)
                self?.setupAnimeStaffs(detail.animeStaffs)
                self?.setupAnimeRecommendations(detail.animeRecommendations)
                self?.setupAnimeReviews(detail.animeReviews)
                self?.setupAnimeScoreDistribution(detail.scoreDistribution)
                self?.setupAnimeStatusDistribution(detail.userStatusDistribution)
                self?.setupAnimeTags(detail.animeTags)
            }
            .store(in: &cancellables)
        
        vm.showCharacterDetailPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] characterID in
                guard let self = self else { return }
                let vc = UIStoryboard(name: "AnimeCharacterPage", bundle: nil).instantiateViewController(identifier: "AnimeCharacterPage") as! AnimeCharacterPageViewController
                vc.viewModel = AnimeCharacterPageViewModel(characterID: characterID)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        vm.showVoiceActorDetailPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] voiceActorID in
                guard let self = self else { return }
                let vc = UIStoryboard(name: "AnimeVoiceActorPage", bundle: nil).instantiateViewController(withIdentifier: "VoiceActorPage") as! AnimeVoiceActorViewController
                vc.viewModel = AnimeVoiceActorPageViewModel(voiceActorID: voiceActorID)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        vm.showAnimeDetailPage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] animeID in
                guard let self = self else { return }
                let vc = AnimeDetailsViewController(animeID: animeID)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
    }
}

private extension AnimeDetailsViewController {
    func setupInformation(_ info: AnimeBasicInfo) {
        if let seasonYear = info.seasonYear {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Year:", infoValue: "\(seasonYear)"))
        }
        
        if let season = info.season {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Season:", infoValue: season))
        }
        
        if let nextAiringEpisode = info.nextAiringEpisode {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Next airing episode:", infoValue: "\(nextAiringEpisode.episode)"))
        }
        
        if let format = info.format {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Format:", infoValue: format))
        }
        
        if let episodes = info.episodes {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Total episodes:", infoValue: "\(episodes)"))
        }
        
        if let duration = info.duration {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Duration:", infoValue: "\(duration) mins"))
        }
        
        if let status = info.status {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Status:", infoValue: status))
        }
        
        if let startDate = info.startDate, let year = startDate.year, let month = startDate.month, let day = startDate.day {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Start date:", infoValue: "\(year)/\(month)/\(day)"))
        }
        
        if let averageScore = info.averageScore {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Average score:", infoValue: "\(averageScore)"))
        }
        
        if let meanScore = info.meanScore {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Mean Score:", infoValue: "\(meanScore)"))
        }
        
        if let popularity = info.popularity {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Popularity:", infoValue: "\(popularity)"))
        }
        
        if let favourites = info.favourites {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Favorites:", infoValue: "\(favourites)"))
        }
        
        if let source = info.source {
            animeStatusHStackView.addArrangedSubview(createSingleInfoStack(infoTitle: "Source:", infoValue: source))
        }
    }
    
    func createSingleInfoStack(infoTitle: String, infoValue: String) -> UIView {
        let contentView: UIView = {
            let view = UIView()
            view.backgroundColor = .atTertiaryBackground
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            return view
        }()
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .atHeadline
            label.textColor = .atTextPrimary
            label.numberOfLines = 1
            label.text = infoTitle
            return label
        }()
        
        let contentLabel: UILabel = {
            let label = UILabel()
            label.font = .atSubheadline
            label.textColor = .atTextSecondary
            label.numberOfLines = 1
            label.text = infoValue
            return label
        }()
        
        let vstack: UIStackView = {
            let stack = UIStackView()
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(contentLabel)
            stack.axis = .vertical
            stack.spacing = 5
            stack.distribution = .fillProportionally
            return stack
        }()
        
        contentView.addSubview(vstack)
        vstack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        return contentView
    }
    
    func setupAnimeDescription(_ description: String) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Description"
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.numberOfLines = 0
            label.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: description)
            return label
        }()
        
        let descriptionContentView: UIView = {
            let view = UIView()
            view.backgroundColor = .atSecondaryBackground
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            return view
        }()
        
        descriptionContentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(5)
            make.top.bottom.equalToSuperview().inset(20)
        }
        
        container.containerView.addArrangedSubview(descriptionContentView)
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeRelations(_ relations: [RelationPreview.Model]) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Relations"
        
        if !relations.isEmpty {
            let scrollView: UIScrollView = {
                let scrollView = UIScrollView()
                return scrollView
            }()
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 10
                return stackView
            }()
            relations.forEach { anime in
                let animeRelationsPreview = RelationPreview(frame: .zero, mediaID: anime.animeID)
                animeRelationsPreview.bind(anime)
                animeRelationsPreview.snp.makeConstraints { make in
                    make.width.equalTo(UIScreen.main.bounds.width * 0.85)
                    make.height.equalTo(180)
                }
                stackView.addArrangedSubview(animeRelationsPreview)
            }
            scrollView.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalTo(scrollView.contentLayoutGuide)
                make.height.equalTo(scrollView.frameLayoutGuide)
            }
            container.containerView.addArrangedSubview(scrollView)
        } else {
            
        }
        
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeCharacters(_ characters: [CharacterPreview.Model]) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Characters"
        
        if !characters.isEmpty {
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                return stackView
            }()
            characters.forEach { character in
                let characterPreview = CharacterPreview()
                characterPreview.bind(character)
                characterPreview.characterTapSubject
                    .subscribe(vm.shouldShowCharacterDetailPage)
                    .store(in: &cancellables)
                characterPreview.voiceActorTapSubject
                    .subscribe(vm.shouldShowVoiceActorDetailPage)
                    .store(in: &cancellables)
                characterPreview.snp.makeConstraints { make in
                    make.height.equalTo(characterPreview.snp.width).multipliedBy(0.25)
                }
                stackView.addArrangedSubview(characterPreview)
            }
            container.containerView.addArrangedSubview(stackView)
        } else {
            
        }
        
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeStaffs(_ staffs: [StaffPreview.Model]) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Staffs"
        
        if !staffs.isEmpty {
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                return stackView
            }()
            staffs.forEach { staff in
                let staffPreview = StaffPreview()
                staffPreview.bind(staff)
                staffPreview.snp.makeConstraints { make in
                    make.height.equalTo(staffPreview.snp.width).multipliedBy(0.25)
                }
                stackView.addArrangedSubview(staffPreview)
            }
            container.containerView.addArrangedSubview(stackView)
        } else {
            
        }
        
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeRecommendations(_ recommendations: [RecommendationsAnimePreview.Model]) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Recommendations"
        
        if !recommendations.isEmpty {
            let scrollView: UIScrollView = {
                let scrollView = UIScrollView()
                scrollView.showsHorizontalScrollIndicator = false
                return scrollView
            }()
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.spacing = 10
                return stackView
            }()
            recommendations.forEach { anime in
                let recommendationsAnimePreview = RecommendationsAnimePreview()
                recommendationsAnimePreview.bind(anime)
                recommendationsAnimePreview.recommendationAnimeTapSubject
                    .subscribe(vm.shouldShowAnimeDetailPage)
                    .store(in: &cancellables)
                recommendationsAnimePreview.snp.makeConstraints { make in
                    make.width.equalTo(UIScreen.main.bounds.width * 0.33)
                }
                stackView.addArrangedSubview(recommendationsAnimePreview)
            }
            scrollView.addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalTo(scrollView.contentLayoutGuide)
                make.height.equalTo(scrollView.frameLayoutGuide)
            }
            container.containerView.addArrangedSubview(scrollView)
        } else {
            
        }
        
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeReviews(_ reviews: [AnimeReview.Model]) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Reviews"
        
        if !reviews.isEmpty {
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                stackView.distribution = .fillProportionally
                return stackView
            }()
            reviews.forEach { review in
                let reviewPreview = AnimeReview()
                reviewPreview.bind(review)
                stackView.addArrangedSubview(reviewPreview)
            }
            container.containerView.addArrangedSubview(stackView)
        } else {
            let reviewEmptyLabel: UILabel = {
                let label = UILabel()
                label.font = .atBody
                label.textColor = .atTextPrimary
                label.numberOfLines = 0
                label.textAlignment = .center
                label.text = "No review available."
                
                return label
            }()
            
            let reviewEmptyView: UIView = {
                let view = UIView()
                view.layer.cornerRadius = 8
                view.clipsToBounds = true
                view.backgroundColor = .atSecondaryBackground
                return view
            }()
            
            reviewEmptyView.addSubview(reviewEmptyLabel)
            reviewEmptyLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(5)
                make.top.bottom.equalToSuperview().inset(20)
            }
            
            container.containerView.addArrangedSubview(reviewEmptyView)
        }
        
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeScoreDistribution(_ scoreDistribution: ScoreDistributionPreview.Model) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Score Distribution"
        let scoreDistributionView = ScoreDistributionPreview()
        scoreDistributionView.bind(scoreDistribution)
        container.containerView.addArrangedSubview(scoreDistributionView)
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeStatusDistribution(_ statusDistribution: UserStatusDistributionPreview.Model) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "User Status Distribution"
        let statusDistributionView = UserStatusDistributionPreview()
        statusDistributionView.bind(statusDistribution)
        container.containerView.addArrangedSubview(statusDistributionView)
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
    
    func setupAnimeTags(_ tags: [TagPreview.Model]) {
        let container = TitleWithContentContaier()
        container.titleLabel.text = "Tags"
        
        if !tags.isEmpty {
            let stackView: UIStackView = {
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.spacing = 5
                stackView.distribution = .fillProportionally
                return stackView
            }()
            tags.forEach { tag in
                let tagPreview = TagPreview()
                tagPreview.bind(tag)
                tagPreview.tagInfoTapSubject
                    .sink { [weak self] description in
                        guard let self = self else { return }
                        let popoverVC = DescriptionPopoverViewController(text: description)
                        
                        // 重要：必須先設定 .popover
                        popoverVC.modalPresentationStyle = .popover
                        
                        if let popover = popoverVC.popoverPresentationController {
                            popover.sourceView = tagPreview.tagInfoButton
                            popover.sourceRect = tagPreview.tagInfoButton.bounds
                            popover.permittedArrowDirections = .any
                            popover.delegate = self
                            popover.backgroundColor = .atSecondaryBackground
                        }
                        
                        self.present(popoverVC, animated: true)
                    }
                    .store(in: &cancellables)
                stackView.addArrangedSubview(tagPreview)
            }
            container.containerView.addArrangedSubview(stackView)
        } else {
            let tagEmptyLabel: UILabel = {
                let label = UILabel()
                label.font = .atBody
                label.textColor = .atTextPrimary
                label.numberOfLines = 0
                label.textAlignment = .center
                label.text = "No tag available."
                
                return label
            }()
            
            let tagEmptyView: UIView = {
                let view = UIView()
                view.layer.cornerRadius = 8
                view.clipsToBounds = true
                view.backgroundColor = .atSecondaryBackground
                return view
            }()
            
            tagEmptyView.addSubview(tagEmptyLabel)
            tagEmptyLabel.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(5)
                make.top.bottom.equalToSuperview().inset(20)
            }
            
            container.containerView.addArrangedSubview(tagEmptyView)
        }
        
        animeDetailsContainerStackView.addArrangedSubview(container)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension AnimeDetailsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // Force popover style on iPhone
    }
    
    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        // Optional: Handle any transition if needed
    }
}

class TitleWithContentContaier: UIView {
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .atBody
        label.textColor = .atTextPrimary
        label.numberOfLines = 1
        return label
    }()
    
    var containerView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        containerView.addArrangedSubview(titleLabel)
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(5)
        }
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        self.backgroundColor = .atTertiaryBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
