//
//  AnimeVoiceActorViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/2.
//

import UIKit

class AnimeVoiceActorViewController: UIViewController {
    
    @IBOutlet weak var voiceActorName: UILabel!
    @IBOutlet weak var voiceActorImage: UIImageView!
    @IBOutlet weak var voiceActorInfoView: UIView!
    @IBOutlet weak var relationContainer: UIView!
    @IBOutlet weak var wholePageScollView: UIScrollView!
    
    var yearSet: Set<Int> = Set<Int>()
    var relationScrollViewBottomAnchor: NSLayoutConstraint?
    
    var voiceActorDataResponse: VoiceActorDataResponse.DataClass.StaffData?
    var isFirstInfo: Bool = true
    
    var lastTimeFetch: TimeInterval = 0
    let fetchDataTimeIntervalLimit: TimeInterval = 2
    
    weak var animeFetchManager: FetchMoreVoiceActorData?
    weak var characterDataFetcher: GetAnimeCharacterDataDelegate?
    weak var animeDetailManager: AnimeDetailDataDelegate?
    
    var relationScrollViewCollection: [RelationScrollView] = []
    var voiceActorDataEachYear: [String: [VoiceActorDataResponse.DataClass.StaffData.CharacterMedia.Edge]] = [String: [VoiceActorDataResponse.DataClass.StaffData.CharacterMedia.Edge]]()
    var collectionviewCollection: [UICollectionView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        setupPage()
        wholePageScollView.delegate = self
        // Do any additional setup after loading the view.
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
    
    fileprivate func setupPage() {
        if let voiceActorDataResponse = voiceActorDataResponse {
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
            
            updateRelationData(voiceActorDataResponse.characterMedia)
            
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AnimeVoiceActorViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == wholePageScollView {
            let now = Date().timeIntervalSince1970
            if now - lastTimeFetch < fetchDataTimeIntervalLimit {
                return
            }
            if voiceActorName.frame.maxY - 3 <= scrollView.contentOffset.y && navigationItem.title!.isEmpty {
                navigationItem.title = voiceActorName.text
            } else if voiceActorName.frame.maxY - 3 > scrollView.contentOffset.y && !navigationItem.title!.isEmpty{
                navigationItem.title = ""
            }
//            print(voiceActorName.frame.maxY - 3, scrollView.contentOffset.y)
            if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height + 50 && scrollView.contentSize.height != 0 {
                
                print("fetch new relation")
                lastTimeFetch = now
                if let hasNextPage = voiceActorDataResponse?.characterMedia?.pageInfo.hasNextPage {
                    if hasNextPage {
                        if let id = voiceActorDataResponse?.id, let page = voiceActorDataResponse?.characterMedia?.pageInfo.currentPage {
                            animeFetchManager?.fetchMoreVoiceActorData(id: id, page: page + 1)
                        }
                    }
                }
            }
//            print(scrollView.contentOffset.y + scrollView.frame.height, scrollView.contentSize.height)
        }
    }
}

extension AnimeVoiceActorViewController: ReceiveMoreVoiceActorData {
    fileprivate func updateRelationData(_ voiceActorData: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia?) {
        if relationScrollViewCollection.count != 0 {
            relationScrollViewBottomAnchor?.isActive = false
        }
        if let voiceActorData = voiceActorData?.edges {
            for (index, data) in voiceActorData.enumerated() {
                if let year = data.node.startDate.year {
                    if !yearSet.contains(year) { // add additional collection view
                        let newRelationScrollView = RelationScrollView()
                        newRelationScrollView.yearLabel.text = "\(year)"
                        newRelationScrollView.translatesAutoresizingMaskIntoConstraints = false
                        self.relationContainer.addSubview(newRelationScrollView)
                        newRelationScrollView.heightAnchor.constraint(equalToConstant: 261).isActive = true
                        newRelationScrollView.leadingAnchor.constraint(equalTo: relationContainer.leadingAnchor).isActive = true
                        newRelationScrollView.trailingAnchor.constraint(equalTo: relationContainer.trailingAnchor).isActive = true
                        if relationScrollViewCollection.count == 0 {
                            newRelationScrollView.topAnchor.constraint(equalTo: relationContainer.topAnchor).isActive = true
                        } else {
                            newRelationScrollView.topAnchor.constraint(equalTo: relationScrollViewCollection.last!.bottomAnchor, constant: 20).isActive = true
                        }
                        relationScrollViewCollection.append(newRelationScrollView)
                        let collectionViewLayout: UICollectionViewFlowLayout = {
                            let layout = UICollectionViewFlowLayout()
                            layout.scrollDirection = .horizontal
                            layout.minimumLineSpacing = 10
                            layout.minimumInteritemSpacing = 10
                            layout.itemSize = CGSize(width: 120, height: 240)
                            return layout
                        }()
                        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
                        collectionView.translatesAutoresizingMaskIntoConstraints = false
                        newRelationScrollView.collectionViewContainer.addSubview(collectionView)
                        collectionView.topAnchor.constraint(equalTo: newRelationScrollView.collectionViewContainer.topAnchor).isActive = true
                        collectionView.bottomAnchor.constraint(equalTo: newRelationScrollView.collectionViewContainer.bottomAnchor).isActive = true
                        collectionView.leadingAnchor.constraint(equalTo: newRelationScrollView.collectionViewContainer.leadingAnchor).isActive = true
                        collectionView.trailingAnchor.constraint(equalTo: newRelationScrollView.collectionViewContainer.trailingAnchor).isActive = true
                        collectionView.dataSource = self
                        collectionView.delegate = self
                        collectionView.tag = year
                        collectionView.register(UINib(nibName: "RelationPreviewCollectionViewCell", bundle: nil).self, forCellWithReuseIdentifier: "voiceActorRelationCollectionView\(collectionView.tag)")
                        collectionviewCollection.append(collectionView)
                        voiceActorDataEachYear["\(year)"] = []
                        voiceActorDataEachYear["\(year)"]?.append(data)
                        yearSet.insert(year)
                    } else {
                        voiceActorDataEachYear["\(year)"]?.append(data)
                    }
                }
            }
            if relationScrollViewCollection.count != 0 {
                relationScrollViewBottomAnchor = relationScrollViewCollection.last!.bottomAnchor.constraint(equalTo: relationContainer.bottomAnchor)
                relationScrollViewBottomAnchor?.isActive = true
            }
        }
        DispatchQueue.main.async {
            self.collectionviewCollection.forEach { collectionView in
                print(self.voiceActorDataEachYear["\(collectionView.tag)"])
                collectionView.reloadData()
            }
        }
    }

    
    func updateVoiceActorData(voiceActorData: VoiceActorDataResponse.DataClass.StaffData.CharacterMedia?) {
        voiceActorDataResponse?.characterMedia?.pageInfo.currentPage = voiceActorData?.pageInfo.currentPage ?? 0
        voiceActorDataResponse?.characterMedia?.pageInfo.hasNextPage = voiceActorData?.pageInfo.hasNextPage ?? false
        print("update page", voiceActorData?.pageInfo.currentPage ?? 0)
        DispatchQueue.main.async {
            self.updateRelationData(voiceActorData)
        }
        
    }
    
    
}

extension AnimeVoiceActorViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return voiceActorDataEachYear[String(collectionView.tag)]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = voiceActorDataEachYear[String(collectionView.tag)]?[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "voiceActorRelationCollectionView\(collectionView.tag)", for: indexPath) as! RelationPreviewCollectionViewCell
        cell.characterImage.loadImage(from: data?.characters.first?.image.large)
        cell.animeTitle.text = data?.node.title.userPreferred
        cell.characterName.text = data?.characters.first?.name.userPreferred
        cell.animeImage.loadImage(from: data?.node.coverImage.large)
        return cell
    }
    
    
}

extension AnimeVoiceActorViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let characterID = voiceActorDataEachYear["\(collectionView.tag)"]?[indexPath.item].characters.first?.id {
            AnimeDataFetcher.shared.fetchCharacterDetailByCharacterID(id: characterID, page: 1) { characterDetail in
                DispatchQueue.main.async {
                    let newVC = UIStoryboard(name: "AnimeCharacterPage", bundle: nil).instantiateViewController(withIdentifier: "CharacterPage") as! AnimeCharacterPageViewController
                    newVC.characterData = characterDetail
//                    newVC.animeDetailManager = AnimeDataFetcher.shared.self
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            }
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
