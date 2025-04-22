//
//  AnimeVoiceActorViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import UIKit
import Combine

class AnimeVoiceActorViewController: UIViewController {
    
    @IBOutlet weak var voiceActorName: UILabel!
    @IBOutlet weak var voiceActorImage: UIImageView!
    @IBOutlet weak var voiceActorInfoView: UIView!
    @IBOutlet weak var wholePageScollView: UIScrollView!
    @IBOutlet weak var relationCollectionView: UICollectionView!
    
    var viewModel: AnimeVoiceActorPageViewModel?
    private var cancellables: Set<AnyCancellable> = []
    let loadMoreVoiceActorDataTrigger: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    var isFirstInfo: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        relationCollectionView.dataSource = self
        relationCollectionView.delegate = self
        
        viewModel?.$voiceActorData
            .prefix(2)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                print("setup page")
                self.setupPage()
            })
            .store(in: &cancellables)
        
        viewModel?.$voiceActorDataEachYear
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                print("reload voice actor data each year")
                self.relationCollectionView.reloadData()
            })
            .store(in: &cancellables)
        
        relationCollectionView.register(UINib(nibName: "RelationPreviewCollectionViewCell", bundle: nil).self, forCellWithReuseIdentifier: "VoiceActorRelationPreviewCell")
        
        viewModel?.bindLoadMoreVoiceActorTriggerToViewModel(trigger: loadMoreVoiceActorDataTrigger)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FloatingButtonManager.shared.addToView(toView: self.view)
        FloatingButtonManager.shared.bringFloatingButtonToFront(in: self.view)
    }
    
    private func setupPage() {
        if let voiceActorDataResponse = viewModel?.voiceActorData {
            navigationItem.title = ""
//            navigationItem.title = voiceActorDataResponse.name.native
            voiceActorName.text = voiceActorDataResponse.name.native
            voiceActorImage.loadImage(from: voiceActorDataResponse.image.large)
            
            var tmpTopAnchorView: UIView! = voiceActorInfoView
            
            if let voiceActorDateOfBirth = voiceActorDataResponse.dateOfBirth {
                // Use voiceActorDateOfBirth here
                print(voiceActorDateOfBirth)
                if let year = voiceActorDateOfBirth.year, let month = voiceActorDateOfBirth.month, let day = voiceActorDateOfBirth.day {
                    let birthStr = AnimeDetailFunc.startDateString(year: year, month: month, day: day)
                    setupLabel(labelName: "Birth:", value: birthStr, topAnchorView: &tmpTopAnchorView)
                }
                
            }
            
            if let voiceActorAge = voiceActorDataResponse.age {
                // Use voiceActorAge here
                setupLabel(labelName: "Age:", value: voiceActorAge.description, topAnchorView: &tmpTopAnchorView)
            }
            
            if let voiceActorGender = voiceActorDataResponse.gender {
                // Use voiceActorGender here
                setupLabel(labelName: "Gender", value: voiceActorGender.description, topAnchorView: &tmpTopAnchorView)
            }
            
            if let voiceActorYearsActive = voiceActorDataResponse.yearsActive {
                // Use voiceActorYearsActive here
                if voiceActorYearsActive.count == 1 {
                    if let startYear = voiceActorYearsActive.first {
                        setupLabel(labelName: "Years Active:", value: "\(startYear)-Present", topAnchorView: &tmpTopAnchorView)
                    }
                } else if voiceActorYearsActive.count == 2 {
                    if let startYear = voiceActorYearsActive.first, let endYear = voiceActorYearsActive.last {
                        setupLabel(labelName: "Years Active:", value: "\(startYear)-\(endYear)", topAnchorView: &tmpTopAnchorView)
                    }
                }
            }
            
            if let voiceActorHomeTown = voiceActorDataResponse.homeTown {
                // Use voiceActorHomeTown here
                setupLabel(labelName: "Hometown:", value: voiceActorHomeTown, topAnchorView: &tmpTopAnchorView)
            }
            
            if let voiceActorBloodType = voiceActorDataResponse.bloodType {
                // Use voiceActorBloodType here
                setupLabel(labelName: "Blood Type:", value: voiceActorBloodType, topAnchorView: &tmpTopAnchorView)
            }
            
            if let voiceActorPrimaryOccupations = voiceActorDataResponse.primaryOccupations {
                // Use voiceActorPrimaryOccupations here
                let primaryOccupations = voiceActorPrimaryOccupations.joined(separator: ", ")
                setupLabel(labelName: "Primary Occupations", value: primaryOccupations, topAnchorView: &tmpTopAnchorView)
            }
            
            
            
            if let voiceActorDateOfDeath = voiceActorDataResponse.dateOfDeath {
                // Use voiceActorDateOfDeath here
                if let year = voiceActorDateOfDeath.year, let month = voiceActorDateOfDeath.month, let day = voiceActorDateOfDeath.day {
                    let deathStr = AnimeDetailFunc.startDateString(year: year, month: month, day: day)
                    setupLabel(labelName: "Death:", value: deathStr, topAnchorView: &tmpTopAnchorView)
                }
            }
            
            if let voiceActorLanguage = voiceActorDataResponse.language {
                // Use voiceActorLanguage here
                setupLabel(labelName: "Language:", value: voiceActorLanguage, topAnchorView: &tmpTopAnchorView)
            }
            
            if let voiceActorDescription = voiceActorDataResponse.description {
                // Use voiceActorDescription here
                let descriptionLabel = UILabel()
                descriptionLabel.numberOfLines = 0
                descriptionLabel.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: voiceActorDescription)
                descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
                
                voiceActorInfoView.addSubview(descriptionLabel)
                if isFirstInfo {
                    descriptionLabel.topAnchor.constraint(equalTo: tmpTopAnchorView.topAnchor, constant: 10).isActive = true
                } else {
                    descriptionLabel.topAnchor.constraint(equalTo: tmpTopAnchorView.bottomAnchor, constant: 10).isActive = true
                }
                descriptionLabel.leadingAnchor.constraint(equalTo: voiceActorInfoView.leadingAnchor).isActive = true
                descriptionLabel.trailingAnchor.constraint(equalTo: voiceActorInfoView.trailingAnchor).isActive = true
                descriptionLabel.bottomAnchor.constraint(equalTo: voiceActorInfoView.bottomAnchor).isActive = true
            }
            
//            updateRelationData(voiceActorDataResponse.characterMedia)
            
        }
    }
    
    func setupLabel(labelName: String, value: String, topAnchorView: inout UIView) {
        let label = UILabel()
        label.text = labelName
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.showsExpansionTextWhenTruncated = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        voiceActorInfoView.addSubview(label)
        
        if isFirstInfo {
            label.topAnchor.constraint(equalTo: topAnchorView.topAnchor).isActive = true
            isFirstInfo = false
        } else {
            label.topAnchor.constraint(equalTo: topAnchorView.bottomAnchor).isActive = true
        }
        label.leadingAnchor.constraint(equalTo: voiceActorInfoView.leadingAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        let valueLabel = UILabel()
        valueLabel.text = value.description
        valueLabel.font = UIFont.systemFont(ofSize: 17)
//        valueLabel.numberOfLines = 0
        valueLabel.sizeToFit()
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        voiceActorInfoView.addSubview(valueLabel)
        
        valueLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
        valueLabel.trailingAnchor.constraint(equalTo: voiceActorInfoView.trailingAnchor).isActive = true
        valueLabel.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
        valueLabel.heightAnchor.constraint(equalToConstant: 21).isActive = true
        
        topAnchorView = label
    }
}

extension AnimeVoiceActorViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == relationCollectionView {
            if let hasNextPage = viewModel?.voiceActorData?.characterMedia?.pageInfo.hasNextPage, hasNextPage && (scrollView.contentOffset.x + scrollView.bounds.width > scrollView.contentSize.width + 10) && !AnimeDataFetcher.shared.isFetchingData {
                loadMoreVoiceActorDataTrigger.send()
            }
        }
    }
}

extension AnimeVoiceActorViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = viewModel else { return 0 }
//        print("sections count", viewModel.voiceActorDataEachYear.keys.count)
        return viewModel.voiceActorDataEachYear.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        let keys = viewModel.voiceActorDataEachYear.keys.sorted(by: >)
//        print("numberOfItemsInSection", viewModel.voiceActorDataEachYear[keys[section]]?.count ?? 0)
        return viewModel.voiceActorDataEachYear[keys[section]]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel else { return UICollectionViewCell() }
        let keys = viewModel.voiceActorDataEachYear.keys.sorted(by: >)
        
        let data = viewModel.voiceActorDataEachYear[keys[indexPath.section]]?[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VoiceActorRelationPreviewCell", for: indexPath) as! RelationPreviewCollectionViewCell
        cell.characterImage.loadImage(from: data?.characters.first?.image.large)
        cell.animeTitle.text = data?.node.title.userPreferred
        cell.characterName.text = data?.characters.first?.name.userPreferred
        cell.animeImage.loadImage(from: data?.node.coverImage.large)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "AnimeVoiceActorCollectionViewHeader",
            for: indexPath) as! AnimeVoiceActorCollectionViewHeader
        guard let viewModel = viewModel else { return header}
        let year = viewModel.voiceActorDataEachYear.keys.sorted(by: >)[indexPath.section]
        
        header.yearLabel.text = "\(year)"
        return header
    }
}

extension AnimeVoiceActorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let keys = viewModel.voiceActorDataEachYear.keys.sorted(by: >)
        if let characterID = viewModel.voiceActorDataEachYear[keys[indexPath.section]]?[indexPath.row].characters.first?.id {
//            AnimeDataFetcher.shared.fetchCharacterDetailByCharacterID(id: characterID, page: 1) { characterDetail in
//                DispatchQueue.main.async {
//                    let newVC = UIStoryboard(name: "AnimeCharacterPage", bundle: nil).instantiateViewController(withIdentifier: "CharacterPage") as! AnimeCharacterPageViewController
//                    newVC.characterData = characterDetail
//                    self.navigationController?.pushViewController(newVC, animated: true)
//                }
//            }
            let vc = UIStoryboard(name: "AnimeCharacterPage", bundle: nil).instantiateViewController(identifier: "AnimeCharacterPage") as! AnimeCharacterPageViewController
            vc.viewModel = AnimeCharacterPageViewModel(characterID: characterID)
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}

//extension AnimeVoiceActorViewController: CharacterIdDelegate {
//    func passCharacterID(characterID: Int) {
//        print(characterID)
//        characterDataFetcher?.getAnimeCharacterData(id: characterID, page: 1)
//    }
//    
//    
//}

class AnimeVoiceActorCollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var yearLabel: UILabel!
    
}
