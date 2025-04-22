//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/15.
//

import UIKit
import Combine

// MARK: - SearchPageViewController
class SearchPageViewController: UIViewController {
    
    // Search
    @IBOutlet weak var searchAnimeTitleTextField: UITextField!
    @IBOutlet weak var genresButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var seasonButton: UIButton!
    @IBOutlet weak var formatButton: UIButton!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var airingStatusButton: UIButton!
    @IBOutlet weak var streamingOnButton: UIButton!
    @IBOutlet weak var countryOfOriginButton: UIButton!
    @IBOutlet weak var sourceMaterialButton: UIButton!
    @IBOutlet weak var doujinSwitch: UISwitch!
    @IBOutlet weak var searchingResultCollectionView: UICollectionView!
    
    var expandedHeightConstraint: NSLayoutConstraint! // 展開搜尋條件欄後的限制
    var foldedHeightConstraint: NSLayoutConstraint! // 折疊後的限制
    private let viewModel: SearchPageViewModel = SearchPageViewModel()
    var cancellable: Set<AnyCancellable> = []
    
    @IBOutlet weak var configScrollView: UIScrollView! // 搜尋條件欄
    
    // 展開/折疊搜尋欄
    @IBAction func expandConfig(_ sender: Any) {
        let isHidden = configScrollView.isHidden
            
        if isHidden {
            foldedHeightConstraint.isActive = false
            expandedHeightConstraint.isActive = true
        } else {
            expandedHeightConstraint.isActive = false
            foldedHeightConstraint.isActive = true
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        configScrollView.isHidden.toggle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 限制height anchor來展開或隱藏搜尋欄
        expandedHeightConstraint = configScrollView.heightAnchor.constraint(equalToConstant: 60)
        foldedHeightConstraint = configScrollView.heightAnchor.constraint(equalToConstant: 0)
        configScrollView.isHidden = true
        foldedHeightConstraint.isActive = true // 預設折疊
        
        searchingResultCollectionView.dataSource = self
        searchingResultCollectionView.delegate = self
        searchingResultCollectionView.register(UINib(nibName: "TrendingAnimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AnimeSearchingCollectionViewCell")
        
        formatButton.setTitle("Select Formats", for: .normal)
        updateMultipleSelectionButtonMenu(button: formatButton, stringArr: AnimeFormat.allCases.map({$0.stringValue}), selectedSet: viewModel.selectedFormatSet, defaultString: "Select Formats") { set in
            self.viewModel.selectedFormatSet = set
        }
        
        genresButton.setTitle("Select Genres", for: .normal)
        streamingOnButton.setTitle("Streaming On", for: .normal)
        
        AnimeDataFetcher.shared.loadAnimeSearchingEssentialData()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { essentialData in
                self.updateMultipleSelectionButtonMenu(button: self.genresButton, stringArr: essentialData.genreCollection, selectedSet: self.viewModel.selectedGenreSet, defaultString: "Select Genres") { set in
                    self.viewModel.selectedGenreSet = set
                }
    
                self.updateMultipleSelectionButtonMenu(button: self.streamingOnButton, stringArr: essentialData.externalLinkSourceCollection.map({$0.site}), selectedSet: self.viewModel.selectedStreamingOnSet, defaultString: "Streaming On") { set in
                    self.viewModel.selectedStreamingOnSet = set
                }
            }
            .store(in: &cancellable)
        
        yearButton.setTitle("Year", for: .normal)
        updateYearSelectionMenu()
        
        seasonButton.setTitle("Season", for: .normal)
        updateSeasonSelectionMenu()
        
        sortButton.setTitle("Select Sort", for: .normal)
        updateSortMenu()
        
        airingStatusButton.setTitle("Select Airing Status", for: .normal)
        updateMultipleSelectionButtonMenu(button: airingStatusButton, stringArr: AnimeAiringStatus.allCases.map({$0.stringValue}), selectedSet: viewModel.selectedAiringStatusSet, defaultString: "Select Airing Status") { set in
            self.viewModel.selectedAiringStatusSet = set
        }
        
        countryOfOriginButton.setTitle("Country", for: .normal)
        updateCountrySelectionMenu()
        
        sourceMaterialButton.setTitle("Source", for: .normal)
        updateMultipleSelectionButtonMenu(button: sourceMaterialButton, stringArr: AnimeSourceMaterial.allCases.map({$0.stringValue}), selectedSet: viewModel.selectedSourceSet, defaultString: "Source") { set in
            self.viewModel.selectedSourceSet = set
        }
        
        
        doujinSwitch.publisher(for: \.isOn)
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .assign(to: \.showDoujin, on: viewModel)
            .store(in: &cancellable)
        
//        doujinSwitch.isOn = viewModel.showDoujin
//        doujinSwitch.addTarget(self, action: #selector(changeDoujinBoolStatus), for: .valueChanged)
        
        searchAnimeTitleTextField.delegate = self
        
        let closeKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
//        searchingResultCollectionView.backgroundView = UIImageView(image: UIImage(systemName: "photo"))
        checkSearchResultIsEmpty()
        
        viewModel.$searchingResult
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.checkSearchResultIsEmpty()
                self.searchingResultCollectionView.reloadData()
                
                if self.viewModel.refreshing {
                    print("refreshing")
                    DispatchQueue.main.async {
                        self.searchingResultCollectionView.setContentOffset(.zero, animated: true)
                    }
                }
            }
            .store(in: &cancellable)
    }
    
    @objc func closeKeyboard(sender: UITapGestureRecognizer) {
        searchAnimeTitleTextField.resignFirstResponder()
    }
    
//    @objc func changeDoujinBoolStatus(sender: UISwitch) {
//        viewModel.showDoujin = sender.isOn
//    }
    
    private func updateMultipleSelectionButtonMenu(button: UIButton, stringArr: [String], selectedSet: Set<String>, defaultString: String, updateSet: @escaping (Set<String>) -> Void) {
        var mutableSet = selectedSet
        let menuActions = stringArr.map { str in
            UIAction(title: str, state: selectedSet.contains(str) ? .on : .off) { action in
                if mutableSet.contains(str) {
                    mutableSet.remove(str)
                } else {
                    mutableSet.insert(str)
                }
                
                // Update the button title
                button.setTitle(mutableSet.isEmpty ? defaultString : mutableSet.joined(separator: ", "), for: .normal)
                updateSet(mutableSet)
                
                // Recreate the menu to reflect the updated selection state
                self.updateMultipleSelectionButtonMenu(button: button, stringArr: stringArr, selectedSet: mutableSet, defaultString: defaultString, updateSet: updateSet)
            }
        }

        // Update the menu on the main thread
        DispatchQueue.main.async {
            button.menu = UIMenu(title: defaultString, options: .displayInline, children: menuActions)
            button.showsMenuAsPrimaryAction = true
        }
    }
    
    
    private func updateSortMenu() {
        let sortMenuActions = AnimeSort.allCases.map({
            return UIAction(title: $0.stringValue, state: viewModel.selectedSort == $0.stringValue ? .on : .off) { action in
//                self.selectedSort = action.title
                if self.viewModel.selectedSort == action.title {
                    self.viewModel.selectedSort = ""
                    self.sortButton.setTitle("Select Sort", for: .normal)
                } else {
                    self.viewModel.selectedSort = action.title
                    self.sortButton.setTitle(action.title, for: .normal)
                }
                self.updateSortMenu()
            }
        })
        DispatchQueue.main.async {
            self.sortButton.menu = UIMenu(title: "Select Sort", options: .displayInline, children: sortMenuActions)
        }
    }
    
    private func updateCountrySelectionMenu() {
        let countryMenuActions = AnimeCountryOfOrigin.allCases.map({
            return UIAction(title: $0.stringValue, state: viewModel.selectedCountry == $0.stringValue ? .on : .off) { action in
                if self.viewModel.selectedCountry == action.title {
                    self.viewModel.selectedCountry = ""
                    self.countryOfOriginButton.setTitle("Country", for: .normal)
                } else {
                    self.viewModel.selectedCountry = action.title
                    self.countryOfOriginButton.setTitle(action.title, for: .normal)
                }
                self.updateCountrySelectionMenu()
            }
        })
        DispatchQueue.main.async {
            self.countryOfOriginButton.menu = UIMenu(title: "Country", options: .displayInline, children: countryMenuActions)
        }
    }
    
    private func updateYearSelectionMenu() {
        let yearMenuActions = PickerData.yearPickerOption.map({
            return UIAction(title: $0.description, state: viewModel.selectedCountry == $0.description ? .on : .off) { action in
                if self.viewModel.selectedSeasonYear?.description == action.title {
                    self.viewModel.selectedSeasonYear = nil
                    self.yearButton.setTitle("Year", for: .normal)
                } else {
                    self.viewModel.selectedSeasonYear = Int(action.title)
                    self.yearButton.setTitle(action.title, for: .normal)
                }
                self.updateYearSelectionMenu()
            }
        })
        DispatchQueue.main.async {
            self.yearButton.menu = UIMenu(title: "Year", options: .displayInline, children: yearMenuActions)
        }
    }
    
    private func updateSeasonSelectionMenu() {
        let seasonMenuActions = PickerData.seasonPickerOption.map({
            return UIAction(title: $0.description, state: viewModel.selectedCountry == $0.description ? .on : .off) { action in
                if self.viewModel.selectedSeason == action.title {
                    self.viewModel.selectedSeason = ""
                    self.seasonButton.setTitle("Season", for: .normal)
                } else {
                    self.viewModel.selectedSeason = action.title
                    self.seasonButton.setTitle(action.title, for: .normal)
                }
                self.updateSeasonSelectionMenu()
            }
        })
        DispatchQueue.main.async {
            self.seasonButton.menu = UIMenu(title: "Season", options: .displayInline, children: seasonMenuActions)
        }
    }
    
    deinit {
        print("SearchingPageViewController deinit")
    }
    
    func checkSearchResultIsEmpty() {
        if (viewModel.searchingResult?.data.Page.media == nil || viewModel.searchingResult?.data.Page.media.count == 0), let frame = searchingResultCollectionView?.frame {
            let emptyView = UIView(frame: frame)
            let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            emptyView.addSubview(imageView)
            
            let infoLabel = UILabel()
            infoLabel.text = "No data found..."
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyView.addSubview(infoLabel)
            
            imageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
            imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
            
            infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15).isActive = true
            infoLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
            infoLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            searchingResultCollectionView.backgroundView = emptyView
        } else {
            searchingResultCollectionView.backgroundView = nil
        }
    }
}

extension SearchPageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource, UICollectionDelegate
extension SearchPageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.searchingResult?.data.Page.media.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnimeSearchingCollectionViewCell", for: indexPath) as! TrendingAnimeCollectionViewCell
        if let animeAllData = viewModel.searchingResult {
            let animeOneData = animeAllData.data.Page.media[indexPath.item]
            if let animeTitle = animeOneData.title.native {
                cell.setCell(title: animeTitle, imageURL: animeOneData.coverImage.extraLarge)
            } else if let animeTitle = animeOneData.title.english {
                cell.setCell(title: animeTitle, imageURL: animeOneData.coverImage.extraLarge)
            } else if let animeTitle = animeOneData.title.romaji {
                cell.setCell(title: animeTitle, imageURL: animeOneData.coverImage.extraLarge)
            }
        } else {
            cell.setCell(title: "", imageURL: nil)
        }
//        self.trendingAnimeCollectionView?.reloadItems(at: [IndexPath(item: indexPath.item, section: 0)])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 20 // Adjusting width with some padding
        let height: CGFloat = 350  // Fixed height for each cell
        
        return CGSize(width: width, height: height)
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 1
//    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 10, bottom: 15, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let animeID = self.viewModel.searchingResult?.data.Page.media[indexPath.item].id {
            let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(withIdentifier: "AnimeDetailView") as! AnimeDetailPageViewController
            vc.viewModel = AnimeDetailPageViewModel(animeID: animeID)
            self.navigationController?.pushViewController(vc, animated: true)
//            AnimeDataFetcher.shared.fetchAnimeByID(id: animeID) { mediaResponse in
//                DispatchQueue.main.async {
//                    let media = mediaResponse.data.media
//                    let vc = AnimeDetailViewController(mediaID: media.id)
//                    vc.animeDetailData = media
//                    vc.navigationItem.title = media.title.native
//                    vc.animeDetailView = AnimeDetailView(frame: self.view.frame)
//                    vc.showOverviewView(sender: vc.animeDetailView.animeBannerView.overviewButton)
//                    vc.fastNavigate = self.tabBarController.self as? any NavigateDelegate
//                    
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let lastTimeReloadData = viewModel.lastTimeFetchData {
            if Date.now.timeIntervalSince(lastTimeReloadData) < 2 {
                print(lastTimeReloadData.timeIntervalSinceNow)
                return
            }
        }
        if scrollView == searchingResultCollectionView {
            if scrollView.contentOffset.y + scrollView.frame.height + 60 > scrollView.contentSize.height && (self.viewModel.searchingResult?.data.Page.pageInfo.hasNextPage ?? false) {
                viewModel.lastTimeFetchData = Date.now
                viewModel.currentPage += 1
            }
        }
    }
    
}

extension SearchPageViewController: NavigateDelegate {
    func navigateTo(page: Int) {
        tabBarController?.selectedIndex = page
    }
    
    
}
