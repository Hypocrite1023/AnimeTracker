//
//  AnimeCharacterPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/1.
//

import UIKit

class AnimeCharacterPageViewController: UIViewController {
    
    // name, image, description, age, gender, bloodType, dateOfBirth,
    
    @IBOutlet weak var characterName: UILabel!
    @IBOutlet weak var characterImage: UIImageView!
    @IBOutlet weak var characterAge: UILabel!
    @IBOutlet weak var characterGender: UILabel!
    @IBOutlet weak var characterBloodType: UILabel!
    @IBOutlet weak var characterDescription: UILabel!
    @IBOutlet weak var languageSelection: UIButton!
    @IBOutlet weak var wholePageScrollView: UIScrollView!
    @IBOutlet weak var characterRelationCollectionView: UICollectionView!
    
    var languageSelected = ""
    weak var animeDetailManager: FetchAnimeDetailDataByID?
    
    var characterData: CharacterDetail? {
        didSet {
            let _ = characterData?.data.Character.media?.edges.map { characterDetail in
                if let voiceActorRoles = characterDetail.voiceActorRoles {
                    for (_, voiceActor) in voiceActorRoles.enumerated() {
                        if !voiceActorLanguageTypeSet.contains(voiceActor.voiceActor.language) {
                            voiceActorLanguageTypeSet.insert(voiceActor.voiceActor.language)
                        }
                    }
                }
            }
            if voiceActorLanguageTypeSet.contains("Japanese") {
                self.characterDataFiltered = self.filterCharacterDataBy(language: "Japanese")
            } else {
                if let lan = voiceActorLanguageTypeSet.first {
                    self.characterDataFiltered = self.filterCharacterDataBy(language: lan)
                }
            }
            
        }
    }
    var characterDataFiltered: CharacterDetail?
    var voiceActorLanguageTypeSet: Set<String> = Set<String>()
    var languageSelectionActions: [UIAction] = []
    
//    fileprivate func setCharacterRelationView(_ characterData: CharacterDetail.CharacterData.CharacterDataInData) {
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        characterRelationCollectionView.dataSource = self
        characterRelationCollectionView.delegate = self
        
        navigationItem.title = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
        wholePageScrollView.delegate = self
        if let characterData = characterDataFiltered?.data.Character {
            navigationItem.title = characterData.name.native
            characterName.text = characterData.name.native
            characterImage.loadImage(from: characterData.image.large)
            characterAge.text = characterData.age
            characterGender.text = characterData.gender?.capitalized
            characterBloodType.text = characterData.bloodType?.uppercased()
            characterDescription.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: characterData.description ?? "")
            
            
            
//            setCharacterRelationView(characterData)
            for (_, language) in voiceActorLanguageTypeSet.enumerated() {
                let languageAction = UIAction(title: language, state: .off) { action in
                    self.characterDataFiltered = self.filterCharacterDataBy(language: language)
                    DispatchQueue.main.async {
                        self.characterRelationCollectionView.reloadData()
                    }
//                    action.state = .on
//                    self.languageSelected = language
//                    self.updateLanguageSelection()
                    self.languageSelection.setTitle(language, for: .normal)
                    if let data = self.characterDataFiltered?.data.Character {
//                        self.setCharacterRelationView(data)
                    }
                    
                }
                languageSelectionActions.append(languageAction)
            }
            
            languageSelection.menu = UIMenu(options: .singleSelection, children: languageSelectionActions)
            if voiceActorLanguageTypeSet.contains("Japanese") {
                languageSelection.setTitle("Japanese", for: .normal)
            } else {
                if let lan = voiceActorLanguageTypeSet.first {
                    languageSelection.setTitle(lan, for: .normal)
                }
            }
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FloatingButtonManager.shared.addToView(toView: self.view)
        FloatingButtonManager.shared.bringFloatingButtonToFront(in: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func updateLanguageSelection() {
        
//        animeDetailView.threadView?.pageControlButton.menu = UIMenu(title: "", children: actions)
//        animeDetailView.threadView?.pageControlButton.showsMenuAsPrimaryAction = true
    }
    
    func filterCharacterDataBy(language lan: String) -> CharacterDetail? {
        var tmpCharacterDataFiltered: CharacterDetail? = characterData ?? nil
        var filteredCharacterData: [CharacterDetail.CharacterData.CharacterDataInData.Media.Edge] = []
        if let characterData = characterData?.data.Character.media?.edges {
            for (index, cData) in characterData.enumerated() {
                if let voiceActorRoles = cData.voiceActorRoles {
                    if voiceActorRoles.count != 0 {
                        var tmpFilteredData: [CharacterDetail.CharacterData.CharacterDataInData.Media.Edge.VoiceActorRoles] = []
                        for (_, voiceActorData) in voiceActorRoles.enumerated() {
                            if voiceActorData.voiceActor.language == lan {
                                tmpFilteredData.append(voiceActorData)
                            }
                        }
                        if tmpFilteredData.count != 0 {
                            var originData = characterData[index]
                            originData.voiceActorRoles = tmpFilteredData
                            filteredCharacterData.append(originData)
                        }
                    } else {
                        let originData = characterData[index]
                        filteredCharacterData.append(originData)
                    }
                    
                }
                
            }
        }
        tmpCharacterDataFiltered?.data.Character.media?.edges = filteredCharacterData
        return tmpCharacterDataFiltered
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

extension AnimeCharacterPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characterDataFiltered?.data.Character.media?.edges.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterRelationCell", for: indexPath) as! CharacterRelationCollectionViewCell
        if let data = characterDataFiltered?.data.Character.media?.edges[indexPath.item] {
            if !(data.node.type == "ANIME") {
                cell.voiceActorImage.isHidden = true
            } else {
                cell.voiceActorImage.isHidden = false
            }
            cell.cellType = data.node.type
            cell.animeCoverImage.loadImage(from: data.node.coverImage.extraLarge)
            cell.animeTitle.text = data.node.title.userPreferred
            cell.voiceActorName.text = data.voiceActorRoles?.first?.voiceActor.name.userPreferred
            cell.voiceActorImage.loadImage(from: data.voiceActorRoles?.first?.voiceActor.image.large)
        }
        return cell
    }
    
}

extension AnimeCharacterPageViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if characterDataFiltered?.data.Character.media?.edges[indexPath.item].node.type == "ANIME" {
            if let animeID = characterDataFiltered?.data.Character.media?.edges[indexPath.item].node.id {
                AnimeDataFetcher.shared.fetchAnimeByID(id: animeID) { mediaResponse in
                    DispatchQueue.main.async {
                        let media = mediaResponse.data.media
                        let vc = AnimeDetailViewController(mediaID: media.id)
                        vc.animeDetailData = media
                        vc.navigationItem.title = media.title.native
                        vc.animeDetailView = AnimeDetailView(frame: self.view.frame)
                        vc.showOverviewView(sender: vc.animeDetailView.animeBannerView.overviewButton)
                        vc.fastNavigate = self.tabBarController.self as? any NavigateDelegate
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}

extension AnimeCharacterPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 238)
    }
}

extension AnimeCharacterPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == wholePageScrollView {
            if scrollView.contentOffset.y > characterName.frame.maxY && navigationItem.title!.isEmpty{
                navigationItem.title = characterName.text
            } else if scrollView.contentOffset.y < characterName.frame.maxY && !navigationItem.title!.isEmpty {
                navigationItem.title = ""
            }
        }
    }
}
