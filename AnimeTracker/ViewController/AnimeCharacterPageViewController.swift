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
    @IBOutlet weak var mediaRelationContainer: UIView!
    @IBOutlet weak var languageSelection: UIButton!
    
    var languageSelected = ""
    
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
    
    fileprivate func setCharacterRelationView(_ characterData: CharacterDetail.CharacterData.CharacterDataInData) {
        for subview in mediaRelationContainer.subviews {
            subview.removeFromSuperview()
        }
        var tmpRelationView: MediaRelationView?
//        print(characterData)
        if let edges = characterData.media?.edges {
            for (index, relation) in edges.enumerated() {
                
                if let voiceActorRoles = relation.voiceActorRoles {
                    print(index, "...")
                    if voiceActorRoles.count != 0 {
                        for (innerIndex, voiceActor) in voiceActorRoles.enumerated() {
                            print(index, innerIndex)
                            let relationView = MediaRelationView()
                            relationView.translatesAutoresizingMaskIntoConstraints = false
                            relationView.animeCoverImage.loadImage(from: relation.node.coverImage.extraLarge)
                            relationView.animeTitle.text = relation.node.title.userPreferred
                            relationView.relationVoiceActor.text = voiceActor.voiceActor.name.userPreferred
                            if !voiceActorLanguageTypeSet.contains(voiceActor.voiceActor.language) {
                                voiceActorLanguageTypeSet.insert(voiceActor.voiceActor.language)
                            }
                            let voiceActorImageView = UIImageView()
                            voiceActorImageView.contentMode = .scaleAspectFit
                            voiceActorImageView.translatesAutoresizingMaskIntoConstraints = false
                            voiceActorImageView.loadImage(from: voiceActor.voiceActor.image.large)
                            relationView.addSubview(voiceActorImageView)
                            voiceActorImageView.heightAnchor.constraint(equalTo: relationView.heightAnchor, multiplier: 0.33).isActive = true
                            voiceActorImageView.widthAnchor.constraint(equalTo: relationView.widthAnchor, multiplier: 0.33).isActive = true
                            voiceActorImageView.trailingAnchor.constraint(equalTo: relationView.trailingAnchor).isActive = true
                            voiceActorImageView.topAnchor.constraint(equalTo: relationView.topAnchor).isActive = true
                            
                            mediaRelationContainer.addSubview(relationView)
                            relationView.topAnchor.constraint(equalTo: mediaRelationContainer.topAnchor).isActive = true
                            relationView.heightAnchor.constraint(equalTo: mediaRelationContainer.heightAnchor).isActive = true
                            relationView.widthAnchor.constraint(equalToConstant: 154).isActive = true
                            if index == 0 {
                                if innerIndex == 0 {
                                    relationView.leadingAnchor.constraint(equalTo: mediaRelationContainer.leadingAnchor).isActive = true
                                    if voiceActorRoles.count == 1 && edges.count == 1{
                                        relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                                    }
                                } else if innerIndex == voiceActorRoles.count - 1 {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                    //                                        relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                                } else {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                }
                            } else if index == edges.count - 1 {
                                if innerIndex == 0 {
                                    relationView.leadingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                                    if voiceActorRoles.count == 1 {
                                        relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                                    }
                                } else if innerIndex == voiceActorRoles.count - 1 {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                    relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                                } else {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                }
                            } else {
                                if innerIndex == 0 {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                } else if innerIndex == voiceActorRoles.count - 1 {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                    //                                        relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                                } else {
                                    relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                                }
                            }
                            tmpRelationView = relationView
                        }
                    } else {
                        print(relation)
                        let relationView = MediaRelationView()
                        relationView.translatesAutoresizingMaskIntoConstraints = false
                        relationView.animeCoverImage.loadImage(from: relation.node.coverImage.extraLarge)
                        relationView.animeTitle.text = relation.node.title.userPreferred
                        relationView.relationVoiceActor.text = ""
                        
                        mediaRelationContainer.addSubview(relationView)
                        
                        relationView.topAnchor.constraint(equalTo: mediaRelationContainer.topAnchor).isActive = true
                        relationView.heightAnchor.constraint(equalTo: mediaRelationContainer.heightAnchor).isActive = true
                        relationView.widthAnchor.constraint(equalToConstant: 154).isActive = true
                        if index == 0 {
                            relationView.leadingAnchor.constraint(equalTo: mediaRelationContainer.leadingAnchor).isActive = true
                            if edges.count == 1 {
                                relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                            }
                        } else if index == edges.count - 1 {
                            relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                            relationView.trailingAnchor.constraint(equalTo: mediaRelationContainer.trailingAnchor).isActive = true
                        } else {
                            relationView.leadingAnchor.constraint(equalTo: tmpRelationView!.trailingAnchor).isActive = true
                        }
                        tmpRelationView = relationView
                    }
                    
                    print("---", voiceActorRoles.count)
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        mediaRelationContainer.translatesAutoresizingMaskIntoConstraints = false
//        mediaRelationContainer.heightAnchor.constraint(equalToConstant: 200).isActive = true
        if let characterData = characterDataFiltered?.data.Character {
            navigationItem.title = characterData.name.native
            characterName.text = characterData.name.native
            characterImage.loadImage(from: characterData.image.large)
            characterAge.text = characterData.age
            characterGender.text = characterData.gender?.capitalized
            characterBloodType.text = characterData.bloodType?.uppercased()
            characterDescription.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: characterData.description ?? "")
            
            
            
            setCharacterRelationView(characterData)
            for (_, language) in voiceActorLanguageTypeSet.enumerated() {
                let languageAction = UIAction(title: language, state: .off) { action in
                    self.characterDataFiltered = self.filterCharacterDataBy(language: language)
//                    action.state = .on
//                    self.languageSelected = language
//                    self.updateLanguageSelection()
                    self.languageSelection.setTitle(language, for: .normal)
                    if let data = self.characterDataFiltered?.data.Character {
                        self.setCharacterRelationView(data)
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
    
    
//    Character(id: 330136) {
//        id
//        name {
//          first
//          middle
//          last
//          full
//          native
//          userPreferred
//          alternative
//          alternativeSpoiler
//        }
//        image{
//          large
//        }
//        favourites
//        isFavourite
//        isFavouriteBlocked
//        description(asHtml: true)
//        age
//        gender
//        bloodType
//        dateOfBirth {
//          year
//          month
//          day
//        }
//        media(page: 1, sort: POPULARITY_DESC, onList: true)@include(if: true) {
//          pageInfo {
//            total
//            perPage
//            currentPage
//            lastPage
//            hasNextPage
//          }
//          edges {
//            id
//            characterRole
//            voiceActorRoles(sort:[RELEVANCE,ID]) {
//              roleNotes
//              voiceActor {
//                id
//                name {
//                  userPreferred
//                }
//                image {
//                  large
//                }
//                language:languageV2
//              }
//            }
//            node {
//              id
//              type
//              isAdult
//              bannerImage
//              title {
//                userPreferred
//              }
//              coverImage {
//                extraLarge
//              }
//              startDate {
//                year
//              }
//              mediaListEntry {
//                id
//                status
//              }
//            }
//          }
//        }
//      }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
