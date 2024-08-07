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
    var relationScrollViews: [RelationScrollView] = []
    var relationViewTrailingAnchorView: [NSLayoutConstraint] = []
    var relationScrollViewBottomAnchor: NSLayoutConstraint?
    
    var voiceActorDataResponse: VoiceActorDataResponse.DataClass.StaffData?
    var isFirstInfo: Bool = true
    
    var lastTimeFetch: TimeInterval = 0
    let fetchDataTimeIntervalLimit: TimeInterval = 2
    
    weak var animeFetchManager: FetchMoreVoiceActorData?
    weak var characterDataFetcher: GetAnimeCharacterDataDelegate?
    weak var animeDetailManager: AnimeDetailDataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        setupPage()
        wholePageScollView.delegate = self
        // Do any additional setup after loading the view.
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
//            if let voiceActorFavourites = voiceActorDataResponse.favourites {
//                // Use voiceActorFavourites here
//            }
//            
//            if let voiceActorIsFavourite = voiceActorDataResponse.isFavourite {
//                // Use voiceActorIsFavourite here
//            }
//            
//            if let voiceActorIsFavouriteBlocked = voiceActorDataResponse.isFavouriteBlocked {
//                // Use voiceActorIsFavouriteBlocked here
//            }
            
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
        var tmpTopAnchorView = relationScrollViews.last ?? relationContainer
        var relationViewIndex = 0
        var tmpRelationViewLeadingAnchorView: UIView! = relationScrollViews.last?.containerInScrollView.subviews.last ?? relationContainer
        var tmpRelationScrollViewTrailingAnchor: NSLayoutConstraint?
        if let voiceActorDataResponseCharacterMedia = voiceActorData?.edges {
            relationViewTrailingAnchorView.last?.isActive = false
            if relationViewTrailingAnchorView.count > 0 {
                relationViewTrailingAnchorView.remove(at: relationViewTrailingAnchorView.count - 1)
            }
            relationScrollViewBottomAnchor?.isActive = false
            for (_, edge) in voiceActorDataResponseCharacterMedia.enumerated() {
                if let year = edge.node.startDate.year {
                    if !yearSet.contains(year) {
                        if relationScrollViews.count != 0 {
                            tmpRelationScrollViewTrailingAnchor = tmpRelationViewLeadingAnchorView.trailingAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.trailingAnchor)
                            relationViewTrailingAnchorView.append(tmpRelationScrollViewTrailingAnchor!)
                            tmpRelationScrollViewTrailingAnchor?.isActive = true
                            print("trailing active")
                        }
                        
                        relationViewIndex = 0
                        yearSet.insert(year)
                        let newRelationScrollView = RelationScrollView()
                        newRelationScrollView.yearLabel.text = year.description
                        newRelationScrollView.translatesAutoresizingMaskIntoConstraints = false
                        relationContainer.addSubview(newRelationScrollView)
                        newRelationScrollView.leadingAnchor.constraint(equalTo: relationContainer.leadingAnchor).isActive = true
                        newRelationScrollView.widthAnchor.constraint(equalTo: relationContainer.widthAnchor).isActive = true
                        newRelationScrollView.heightAnchor.constraint(equalToConstant: 250).isActive = true
                        if relationScrollViews.count == 0 {
                            newRelationScrollView.topAnchor.constraint(equalTo: tmpTopAnchorView!.topAnchor).isActive = true
                        } else {
                            newRelationScrollView.topAnchor.constraint(equalTo: relationScrollViews.last!.bottomAnchor).isActive = true
                        }
                        relationScrollViews.append(newRelationScrollView)
                        tmpTopAnchorView = newRelationScrollView
                        tmpRelationViewLeadingAnchorView = newRelationScrollView.containerInScrollView
                    }
                    for (_, character) in edge.characters.enumerated() {
                        let relationView = MediaRelationView(frame: .zero, animeID: nil, characterID: character.id)
                        relationView.characterIdDelegate = self
                        relationView.translatesAutoresizingMaskIntoConstraints = false
                        relationView.animeCoverImage.contentMode = .scaleAspectFill
                        relationView.animeCoverImage.loadImage(from: character.image.large)
                        relationView.animeTitle.text = character.name.userPreferred
                        relationView.relationVoiceActor.text = edge.node.title.userPreferred
                        
                        let voiceActorImageView = UIImageView()
                        voiceActorImageView.contentMode = .scaleAspectFit
                        voiceActorImageView.translatesAutoresizingMaskIntoConstraints = false
                        voiceActorImageView.loadImage(from: edge.node.coverImage.large)
                        relationView.addSubview(voiceActorImageView)
                        voiceActorImageView.heightAnchor.constraint(equalTo: relationView.heightAnchor, multiplier: 0.33).isActive = true
                        voiceActorImageView.widthAnchor.constraint(equalTo: relationView.widthAnchor, multiplier: 0.33).isActive = true
                        voiceActorImageView.trailingAnchor.constraint(equalTo: relationView.trailingAnchor).isActive = true
                        voiceActorImageView.topAnchor.constraint(equalTo: relationView.topAnchor).isActive = true
                        
                        relationScrollViews.last!.containerInScrollView.addSubview(relationView)
                        
                        relationView.topAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.topAnchor).isActive = true
                        relationView.heightAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.heightAnchor).isActive = true
                        relationView.widthAnchor.constraint(equalToConstant: 120).isActive = true
//                        print(relationViewIndex, "------")
                        if relationViewIndex == 0 {
                            if relationScrollViews.last!.containerInScrollView.subviews.count == 1 {
                                relationView.leadingAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.leadingAnchor).isActive = true
                            } else {
                                relationView.leadingAnchor.constraint(equalTo: tmpRelationViewLeadingAnchorView.trailingAnchor).isActive = true
                            }
                        } else {
                            relationView.leadingAnchor.constraint(equalTo: tmpRelationViewLeadingAnchorView.trailingAnchor, constant: 10).isActive = true
                        }
                        tmpRelationViewLeadingAnchorView = relationView
                        relationViewIndex += 1
                    }
                } else {
                    if !yearSet.contains(0) {
                        
                        let newRelationScrollView = RelationScrollView()
                        newRelationScrollView.yearLabel.text = "TBA"
                        newRelationScrollView.translatesAutoresizingMaskIntoConstraints = false
                        relationContainer.addSubview(newRelationScrollView)
                        newRelationScrollView.leadingAnchor.constraint(equalTo: relationContainer.leadingAnchor).isActive = true
                        newRelationScrollView.widthAnchor.constraint(equalTo: relationContainer.widthAnchor).isActive = true
                        newRelationScrollView.heightAnchor.constraint(equalToConstant: 250).isActive = true
                        if relationScrollViews.count == 0 {
                            newRelationScrollView.topAnchor.constraint(equalTo: tmpTopAnchorView!.topAnchor).isActive = true
                        } else {
                            newRelationScrollView.topAnchor.constraint(equalTo: relationScrollViews.last!.bottomAnchor, constant: 10).isActive = true
                        }
                        relationScrollViews.append(newRelationScrollView)
                        
                        tmpTopAnchorView = newRelationScrollView
                        yearSet.insert(0)
                    }
                    
                    
                    for (_, character) in edge.characters.enumerated() {
                        let relationView = MediaRelationView(frame: .zero, animeID: nil, characterID: character.id)
                        relationView.characterIdDelegate = self
                        relationView.translatesAutoresizingMaskIntoConstraints = false
                        relationView.animeCoverImage.loadImage(from: character.image.large)
                        relationView.animeTitle.text = character.name.userPreferred
                        relationView.relationVoiceActor.text = edge.node.title.userPreferred
                        
                        let voiceActorImageView = UIImageView()
                        voiceActorImageView.contentMode = .scaleAspectFit
                        voiceActorImageView.translatesAutoresizingMaskIntoConstraints = false
                        voiceActorImageView.loadImage(from: edge.node.coverImage.large)
                        relationView.addSubview(voiceActorImageView)
                        voiceActorImageView.heightAnchor.constraint(equalTo: relationView.heightAnchor, multiplier: 0.33).isActive = true
                        voiceActorImageView.widthAnchor.constraint(equalTo: relationView.widthAnchor, multiplier: 0.33).isActive = true
                        voiceActorImageView.trailingAnchor.constraint(equalTo: relationView.trailingAnchor).isActive = true
                        voiceActorImageView.topAnchor.constraint(equalTo: relationView.topAnchor).isActive = true
                        
                        relationScrollViews.last!.containerInScrollView.addSubview(relationView)
                        
                        relationView.topAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.topAnchor).isActive = true
                        relationView.heightAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.heightAnchor).isActive = true
                        relationView.widthAnchor.constraint(equalToConstant: 120).isActive = true
//                        print(relationViewIndex, "------")
                        if relationViewIndex == 0 {
                            if relationScrollViews.last!.containerInScrollView.subviews.count == 1 {
                                relationView.leadingAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.leadingAnchor).isActive = true
                            } else {
                                relationView.leadingAnchor.constraint(equalTo: tmpRelationViewLeadingAnchorView.trailingAnchor).isActive = true
                            }
                            
                        } else {
                            relationView.leadingAnchor.constraint(equalTo: tmpRelationViewLeadingAnchorView.trailingAnchor, constant: 10).isActive = true
                        }
                        tmpRelationViewLeadingAnchorView = relationView
                        relationViewIndex += 1
                    }
                }
            }
            tmpRelationScrollViewTrailingAnchor = tmpRelationViewLeadingAnchorView.trailingAnchor.constraint(equalTo: relationScrollViews.last!.containerInScrollView.trailingAnchor)
            tmpRelationScrollViewTrailingAnchor?.isActive = true
            relationViewTrailingAnchorView.append(tmpRelationScrollViewTrailingAnchor!)
            tmpRelationScrollViewTrailingAnchor?.isActive = true
            if let lastrelationScrollView = relationScrollViews.last {
                relationScrollViewBottomAnchor = lastrelationScrollView.bottomAnchor.constraint(equalTo: relationContainer.bottomAnchor)
                relationScrollViewBottomAnchor?.isActive = true
                
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

extension AnimeVoiceActorViewController: CharacterIdDelegate {
    func passCharacterID(characterID: Int) {
        print(characterID)
        characterDataFetcher?.getAnimeCharacterData(id: characterID, page: 1)
    }
    
    
}
