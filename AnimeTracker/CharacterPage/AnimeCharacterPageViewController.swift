//
//  AnimeCharacterPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/1.
//

import UIKit
import Combine

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
    
    var viewModel: AnimeCharacterPageViewModel?
    private var cancellables: Set<AnyCancellable> = []
    

    var languageSelectionActions: [UIAction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        characterRelationCollectionView.dataSource = self
        characterRelationCollectionView.delegate = self
        
        navigationItem.title = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
        wholePageScrollView.delegate = self
        
        viewModel?.$characterData
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                
            }, receiveValue: { characterDataFiltered in
                guard let characterData = characterDataFiltered?.data.Character else {
                    return
                }
                self.navigationItem.title = characterData.name.native
                self.characterName.text = characterData.name.native
                self.characterImage.loadImage(from: characterData.image.large)
                self.characterAge.text = characterData.age
                self.characterGender.text = characterData.gender?.capitalized
                self.characterBloodType.text = characterData.bloodType?.uppercased()
                self.characterDescription.attributedText = AnimeDetailFunc.updateAnimeDescription(animeDescription: characterData.description ?? "")
                guard let languageTypeSet = self.viewModel?.voiceActorLanguageTypeSet else { return }
                for (_, language) in languageTypeSet.enumerated() {
                    let languageAction = UIAction(title: language, state: .off) { action in
                        self.viewModel?.filterCharacterDataBy(language: language)
                        
                        self.languageSelection.setTitle(language, for: .normal)
                    }
                    self.languageSelectionActions.append(languageAction)
                }
                self.languageSelection.menu = UIMenu(options: .singleSelection, children: self.languageSelectionActions)
                if languageTypeSet.contains("Japanese") {
                    self.languageSelection.setTitle("Japanese", for: .normal)
                } else {
                    if let lan = languageTypeSet.first {
                        self.languageSelection.setTitle(lan, for: .normal)
                    }
                }
            })
            .store(in: &cancellables)
        
        viewModel?.$characterDataFiltered
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                DispatchQueue.main.async {
                    self.characterRelationCollectionView.reloadData()
                }
            })
            .store(in: &cancellables)
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
}

extension AnimeCharacterPageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.characterDataFiltered?.data.Character.media?.edges.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterRelationCell", for: indexPath) as! CharacterRelationCollectionViewCell
        if let data = viewModel?.characterDataFiltered?.data.Character.media?.edges[indexPath.item] {
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
        if viewModel?.characterDataFiltered?.data.Character.media?.edges[indexPath.item].node.type == "ANIME" {
            if let animeID = viewModel?.characterDataFiltered?.data.Character.media?.edges[indexPath.item].node.id {
                let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(identifier: "AnimeDetailView") as! AnimeDetailPageViewController
                vc.viewModel = AnimeDetailPageViewModel(animeID: animeID)
                navigationController?.pushViewController(vc, animated: true)
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
