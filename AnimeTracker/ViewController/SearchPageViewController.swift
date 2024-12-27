//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/15.
//

import UIKit

enum AnimeFormat: String, CaseIterable {
    case TVSHOW = "TV Show"
    case MOVIE = "Movie"
    case TVSHORT = "TV Short"
    case SPECIAL = "Special"
    case OVA = "OVA"
    case ONA = "ONA"
    case MUSIC = "Music"
    
    var stringValue: String {
        switch(self) {
            
        case .TVSHOW:
            return "TV Show"
        case .MOVIE:
            return "Movie"
        case .TVSHORT:
            return "TV Short"
        case .SPECIAL:
            return "Special"
        case .OVA:
            return "OVA"
        case .ONA:
            return "ONA"
        case .MUSIC:
            return "Music"
        }
    }
    
    var apiUse: String {
        switch self {
            
        case .TVSHOW:
            "TV"
        case .MOVIE:
            "MOVIE"
        case .TVSHORT:
            "TV_SHORT"
        case .SPECIAL:
            "SPECIAL"
        case .OVA:
            "OVA"
        case .ONA:
            "ONA"
        case .MUSIC:
            "MUSIC"
        }
    }
    
    init?(str: String) {
        if let format = AnimeFormat(rawValue: str) {
            self = format
        } else {
            return nil
        }
    }
}

enum AnimeSort: String, CaseIterable {
    case Title = "Title"
    case Popularity = "Popularity"
    case AverageScore = "Average Score"
    case Trending = "Trending"
    case Favorites = "Favorites"
    case DateAdded = "Date Added"
    case ReleaseDate = "Release Date"
    var stringValue: String {
        switch(self) {
            
        case .Title:
            "Title"
        case .Popularity:
            "Popularity"
        case .AverageScore:
            "Average Score"
        case .Trending:
            "Trending"
        case .Favorites:
            "Favorites"
        case .DateAdded:
            "Date Added"
        case .ReleaseDate:
            "Release Date"
        }
    }
    
    var apiUse: String {
        switch self {
            
        case .Title:
            "TITLE_NATIVE"
        case .Popularity:
            "POPULARITY_DESC"
        case .AverageScore:
            "SCORE_DESC"
        case .Trending:
            "TRENDING_DESC"
        case .Favorites:
            "FAVOURITES_DESC"
        case .DateAdded:
            "UPDATED_AT"
        case .ReleaseDate:
            "START_DATE_DESC"
        }
    }
    init?(str: String) {
        if let sort = AnimeSort(rawValue: str) {
            self = sort
        } else {
            return nil
        }
    }
}

enum AnimeAiringStatus: String, CaseIterable {
    case Airing = "Airing"
    case Finished = "Finished"
    case NotYetAired = "Not Yet Aired"
    case Cancelled = "Cancelled"
    
    var stringValue: String {
        switch self {
            
        case .Airing:
            "Airing"
        case .Finished:
            "Finished"
        case .NotYetAired:
            "Not Yet Aired"
        case .Cancelled:
            "Cancelled"
        }
    }
    var apiUse: String {
        switch self {
            
        case .Airing:
            "RELEASING"
        case .Finished:
            "FINISHED"
        case .NotYetAired:
            "NOT_YET_RELEASED"
        case .Cancelled:
            "CANCELLED"
        }
    }
    
    init?(str: String) {
        self = AnimeAiringStatus(rawValue: str)!
    }
}

enum AnimeCountryOfOrigin: String, CaseIterable {
    case Japan = "Japan"
    case Taiwan = "Taiwan"
    case SouthKorea = "South Korea"
    case China = "China"
    
    var stringValue: String {
        switch self {
            
        case .Japan:
            "Japan"
        case .Taiwan:
            "Taiwan"
        case .SouthKorea:
            "South Korea"
        case .China:
            "China"
        }
    }
    
    var apiUse: String {
        switch self {
        case .Japan:
            "JP"
        case .Taiwan:
            "TW"
        case .SouthKorea:
            "KR"
        case .China:
            "CN"
        }
    }
    
    init?(fromString string: String) {
        if let country = AnimeCountryOfOrigin(rawValue: string) {
            self = country
        } else {
            return nil
        }
    }
    
}

enum AnimeSourceMaterial: String, CaseIterable {
    case Original = "Original"
    case Manga = "Manga"
    case LightNovel = "Light Novel"
    case WebNovel = "Web Novel"
    case Novel = "Novel"
    case Anime = "Anime"
    case VisualNovel = "Visual Novel"
    case VideoGame = "Video Game"
    case Doujinshi = "Doujinshi"
    case Comic = "Comic"
    case LiveAction = "Live Action"
    case Game = "Game"
    case MultimediaProject = "Multimedia Project"
    
    init?(from string: String) {
        if let source = AnimeSourceMaterial(rawValue: string) {
            self = source
        } else {
            return nil
        }
    }
    
    var stringValue: String {
        switch self {
        case .Original:
            "Original"
        case .Manga:
            "Manga"
        case .LightNovel:
            "Light Novel"
        case .WebNovel:
            "Web Novel"
        case .Novel:
            "Novel"
        case .Anime:
            "Anime"
        case .VisualNovel:
            "Visual Novel"
        case .VideoGame:
            "Video Game"
        case .Doujinshi:
            "Doujinshi"
        case .Comic:
            "Comic"
        case .LiveAction:
            "Live Action"
        case .Game:
            "Game"
        case .MultimediaProject:
            "Multimedia Project"
        }
    }
    
    var apiUse: String {
        switch self {
        case .Original:
            "ORIGINAL"
        case .Manga:
            "MANGA"
        case .LightNovel:
            "LIGHT_NOVEL"
        case .WebNovel:
            "WEB_NOVEL"
        case .Novel:
            "NOVEL"
        case .Anime:
            "ANIME"
        case .VisualNovel:
            "VISUAL_NOVEL"
        case .VideoGame:
            "VIDEO_GAME"
        case .Doujinshi:
            "DOUJINSHI"
        case .Comic:
            "COMIC"
        case .LiveAction:
            "LIVE_ACTION"
        case .Game:
            "GAME"
        case .MultimediaProject:
            "MULTIMEDIA_PROJECT"
        }
    }
}

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
    
    
    @IBOutlet weak var trendingAnimeCollectionView: UICollectionView?
    
    var expandedHeightConstraint: NSLayoutConstraint!
    var foldedHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var configScrollView: UIScrollView!
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
    
    var animeData: AnimeSearchedOrTrending?
    
    var genres: [String] = [] {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedGenreSet: Set<String> = Set<String>() {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedFormatSet: Set<String> = Set<String>() {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedSort: String = "" {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedAiringStatusSet: Set<String> = Set<String>() {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedStreamingOnSet: Set<String> = Set<String>() {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedCountry: String = "" {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedSourceSet: Set<String> = Set<String>() {
        didSet {
            dataCurrentPage = 0
        }
    }
    var showDoujin: Bool = false {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedSeasonYear: Int? {
        didSet {
            dataCurrentPage = 0
        }
    }
    var selectedSeason: String = "" {
        didSet {
            dataCurrentPage = 0
        }
    }

    var lastTimeReloadData: Date?
    var dataCurrentPage = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        expandedHeightConstraint = configScrollView.heightAnchor.constraint(equalToConstant: 60)
            foldedHeightConstraint = configScrollView.heightAnchor.constraint(equalToConstant: 0)
        configScrollView.isHidden = true
        foldedHeightConstraint.isActive = true
        print("load search page")
        AnimeDataFetcher.shared.animeDataDelegateManager = self
        AnimeDataFetcher.shared.animeOverViewDataDelegate = self
        
        
        
        trendingAnimeCollectionView?.dataSource = self
        trendingAnimeCollectionView?.delegate = self
        trendingAnimeCollectionView?.register(SearchingAnimeCollectionViewCell.self, forCellWithReuseIdentifier: "searchCell")
        
        formatButton.setTitle("Select Formats", for: .normal)
        updateMultipleSelectionButtonMenu(button: formatButton, stringArr: AnimeFormat.allCases.map({$0.stringValue}), selectedSet: selectedFormatSet, defaultString: "Select Formats") { set in
            self.selectedFormatSet = set
            self.searchChangeLoadData()
        }
        
        genresButton.setTitle("Select Genres", for: .normal)
        streamingOnButton.setTitle("Streaming On", for: .normal)
        
        AnimeDataFetcher.shared.loadEssentialData { essentialData in
            print(essentialData.genreCollection)
            self.updateMultipleSelectionButtonMenu(button: self.genresButton, stringArr: essentialData.genreCollection, selectedSet: self.selectedGenreSet, defaultString: "Select Genres") { set in
                self.selectedGenreSet = set
                self.searchChangeLoadData()
            }
            
            self.updateMultipleSelectionButtonMenu(button: self.streamingOnButton, stringArr: essentialData.externalLinkSourceCollection.map({$0.site}), selectedSet: self.selectedStreamingOnSet, defaultString: "Streaming On") { set in
                self.selectedStreamingOnSet = set
                self.searchChangeLoadData()
            }
        }
        
        yearButton.setTitle("Year", for: .normal)
        self.updateYearSelectionMenu()
        
        seasonButton.setTitle("Season", for: .normal)
        self.updateSeasonSelectionMenu()
        
        sortButton.setTitle("Select Sort", for: .normal)
        self.updateSortMenu()
        
        airingStatusButton.setTitle("Select Airing Status", for: .normal)
        updateMultipleSelectionButtonMenu(button: airingStatusButton, stringArr: AnimeAiringStatus.allCases.map({$0.stringValue}), selectedSet: selectedAiringStatusSet, defaultString: "Select Airing Status") { set in
            self.selectedAiringStatusSet = set
            self.searchChangeLoadData()
        }
        
        countryOfOriginButton.setTitle("Country", for: .normal)
        updateCountrySelectionMenu()
        
        sourceMaterialButton.setTitle("Source", for: .normal)
        updateMultipleSelectionButtonMenu(button: sourceMaterialButton, stringArr: AnimeSourceMaterial.allCases.map({$0.stringValue}), selectedSet: selectedSourceSet, defaultString: "Source") { set in
            self.selectedSourceSet = set
            self.searchChangeLoadData()
        }
        
        doujinSwitch.isOn = showDoujin
        doujinSwitch.addTarget(self, action: #selector(changeDoujinBoolStatus), for: .valueChanged)
        
        searchAnimeTitleTextField.delegate = self
    }
    
    @objc func changeDoujinBoolStatus(sender: UISwitch) {
        self.showDoujin = sender.isOn
        searchChangeLoadData()
        print("showDoujin", showDoujin)
    }
    
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
            return UIAction(title: $0.stringValue, state: selectedSort == $0.stringValue ? .on : .off) { action in
//                self.selectedSort = action.title
                if self.selectedSort == action.title {
                    self.selectedSort = ""
                    self.sortButton.setTitle("Select Sort", for: .normal)
                } else {
                    self.selectedSort = action.title
                    self.sortButton.setTitle(action.title, for: .normal)
                }
                self.searchChangeLoadData()
                self.updateSortMenu()
            }
        })
        DispatchQueue.main.async {
            self.sortButton.menu = UIMenu(title: "Select Sort", options: .displayInline, children: sortMenuActions)
        }
    }
    
    private func updateCountrySelectionMenu() {
        let countryMenuActions = AnimeCountryOfOrigin.allCases.map({
            return UIAction(title: $0.stringValue, state: selectedCountry == $0.stringValue ? .on : .off) { action in
                if self.selectedCountry == action.title {
                    self.selectedCountry = ""
                    self.countryOfOriginButton.setTitle("Country", for: .normal)
                } else {
                    self.selectedCountry = action.title
                    self.countryOfOriginButton.setTitle(action.title, for: .normal)
                }
                self.searchChangeLoadData()
                self.updateCountrySelectionMenu()
            }
        })
        DispatchQueue.main.async {
            self.countryOfOriginButton.menu = UIMenu(title: "Country", options: .displayInline, children: countryMenuActions)
        }
    }
    
    private func updateYearSelectionMenu() {
        let yearMenuActions = PickerData.yearPickerOption.map({
            return UIAction(title: $0.description, state: selectedCountry == $0.description ? .on : .off) { action in
                if self.selectedSeasonYear?.description == action.title {
                    self.selectedSeasonYear = nil
                    self.yearButton.setTitle("Year", for: .normal)
                } else {
                    self.selectedSeasonYear = Int(action.title)
                    self.yearButton.setTitle(action.title, for: .normal)
                }
                self.searchChangeLoadData()
                self.updateYearSelectionMenu()
            }
        })
        DispatchQueue.main.async {
            self.yearButton.menu = UIMenu(title: "Year", options: .displayInline, children: yearMenuActions)
        }
    }
    
    private func updateSeasonSelectionMenu() {
        let seasonMenuActions = PickerData.seasonPickerOption.map({
            return UIAction(title: $0.description, state: selectedCountry == $0.description ? .on : .off) { action in
                if self.selectedSeason == action.title {
                    self.selectedSeason = ""
                    self.seasonButton.setTitle("Season", for: .normal)
                } else {
                    self.selectedSeason = action.title
                    self.seasonButton.setTitle(action.title, for: .normal)
                }
                self.searchChangeLoadData()
                self.updateSeasonSelectionMenu()
            }
        })
        DispatchQueue.main.async {
            self.seasonButton.menu = UIMenu(title: "Season", options: .displayInline, children: seasonMenuActions)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    deinit {
        print("SearchingPageViewController deinit")
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

extension SearchPageViewController: UITextFieldDelegate {
    fileprivate func searchChangeLoadData() {
        print("load data")
        AnimeDataFetcher.shared.searchAnime(title: searchAnimeTitleTextField.text ?? "", genres: selectedGenreSet.map({$0}), format: selectedFormatSet.compactMap({AnimeFormat(str: $0)?.apiUse}), sort: AnimeSort(str: selectedSort)?.apiUse ?? "", airingStatus: selectedAiringStatusSet.map({AnimeAiringStatus(rawValue: $0)!.apiUse}), streamingOn: selectedStreamingOnSet.map({$0}), country: AnimeCountryOfOrigin(fromString: selectedCountry)?.apiUse ?? "", sourceMaterial: selectedSourceSet.map({AnimeSourceMaterial(from: $0)!.apiUse}), doujin: showDoujin, year: selectedSeasonYear, season: selectedSeason, page: dataCurrentPage) { animeData in
            
            if animeData.data.Page.pageInfo.currentPage == 1 {
                self.animeData = animeData
            } else {
                self.animeData?.data.Page.media += animeData.data.Page.media
                self.animeData?.data.Page.pageInfo.hasNextPage = animeData.data.Page.pageInfo.hasNextPage
            }
            
            DispatchQueue.main.async {
                self.trendingAnimeCollectionView?.reloadData()
                if self.dataCurrentPage == 0 {
                    UIView.animate(withDuration: 0.5) {
                        self.trendingAnimeCollectionView?.contentOffset.y = 0
                    }
                }
            }
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchAnimeTitleTextField {
            searchChangeLoadData()
        }
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
        return animeData?.data.Page.media.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchingAnimeCollectionViewCell
        if let animeAllData = self.animeData {
            let animeOneData = animeAllData.data.Page.media[indexPath.item]
            if let animeTitle = animeOneData.title.native {
                cell.setup(title: animeTitle, imageURL: animeOneData.coverImage.extraLarge)
            } else if let animeTitle = animeOneData.title.english {
                cell.setup(title: animeTitle, imageURL: animeOneData.coverImage.extraLarge)
            } else if let animeTitle = animeOneData.title.romaji {
                cell.setup(title: animeTitle, imageURL: animeOneData.coverImage.extraLarge)
            }
        } else {
            cell.setup(title: "", imageURL: nil)
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
        if let animeID = self.animeData?.data.Page.media[indexPath.item].id {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let lastTimeReloadData = lastTimeReloadData {
            if Date.now.timeIntervalSince(lastTimeReloadData) < 2 {
                print(lastTimeReloadData.timeIntervalSinceNow)
                return
            }
        }
        if scrollView == trendingAnimeCollectionView {
            if scrollView.contentOffset.y + scrollView.frame.height + 60 > scrollView.contentSize.height && (self.animeData?.data.Page.pageInfo.hasNextPage ?? false) {
                lastTimeReloadData = Date.now
                self.dataCurrentPage += 1
                searchChangeLoadData()
            }
        }
    }
    
}

extension SearchPageViewController: AnimeDataDelegate {
    func passAnimeData(animeData: AnimeSearchedOrTrending) {
        self.animeData = animeData

        DispatchQueue.main.async {
            self.trendingAnimeCollectionView?.reloadData()
        }
    }

}

extension SearchPageViewController: AnimeOverViewDataDelegate {
    func animeDetailDataDelegate(media: MediaResponse.MediaData.Media) {
        DispatchQueue.main.async {
            let vc = AnimeDetailViewController(mediaID: media.id)
            vc.animeDetailData = media
            vc.navigationItem.title = media.title.native
            vc.animeDetailView = AnimeDetailView(frame: self.view.frame)
            vc.showOverviewView(sender: vc.animeDetailView.animeBannerView.overviewButton)
            vc.fastNavigate = self.tabBarController as? NavigateDelegate
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}

extension SearchPageViewController: NavigateDelegate {
    func navigateTo(page: Int) {
        tabBarController?.selectedIndex = page
    }
    
    
}
