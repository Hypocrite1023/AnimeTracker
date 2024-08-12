//
//  TrendingPageViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/15.
//

import UIKit

enum AnimeFormat: CaseIterable {
    case TVSHOW, MOVIE, TVSHORT, SPECIAL, OVA, ONA, MUSIC
    
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
}

class SearchPageViewController: UIViewController {
    
    // Search
    @IBOutlet weak var serchAnimeTitleTextField: UITextField!
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
    var yearTableView: UITableView!
    var seasonTableView: UITableView!
//    let apiManager = AnimeDataFetcher()
//    var images: [UIImage?] = Array(repeating: nil, count: 10)
    var animeData: AnimeSearchedOrTrending?
    
    var genres: [String] = []

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
        
        yearButton.setTitle(PickerData.yearPickerOption.last?.description, for: .normal)
        yearButton.addTarget(self, action: #selector(yearButtonTap), for: .touchUpInside)
        
        yearTableView = UITableView()
        yearTableView.isHidden = true
        self.view.addSubview(yearTableView)
        yearTableView.register(UITableViewCell.self, forCellReuseIdentifier: "yearCell")
        yearTableView?.translatesAutoresizingMaskIntoConstraints = false
        yearTableView?.delegate = self
        yearTableView?.dataSource = self
        
        NSLayoutConstraint.activate([
            yearTableView.centerXAnchor.constraint(equalTo: yearButton.centerXAnchor),
            yearTableView.topAnchor.constraint(equalTo: yearButton.bottomAnchor),
            yearTableView.heightAnchor.constraint(equalToConstant: 200),
            yearTableView.widthAnchor.constraint(equalTo: yearButton.widthAnchor)
        ])
        
        seasonButton.setTitle(PickerData.seasonPickerOption.first, for: .normal)
        seasonButton?.addTarget(self, action: #selector(seasonButtonTap), for: .touchUpInside)
        
        seasonTableView = UITableView()
        seasonTableView.isHidden = true
        self.view.addSubview(seasonTableView)
        seasonTableView.register(UITableViewCell.self, forCellReuseIdentifier: "seasonCell")
        seasonTableView?.translatesAutoresizingMaskIntoConstraints = false
        seasonTableView?.delegate = self
        seasonTableView?.dataSource = self
        
        NSLayoutConstraint.activate([
            seasonTableView.centerXAnchor.constraint(equalTo: seasonButton.centerXAnchor),
            seasonTableView.topAnchor.constraint(equalTo: seasonButton.bottomAnchor),
            seasonTableView.heightAnchor.constraint(equalToConstant: 200),
            seasonTableView.widthAnchor.constraint(equalTo: seasonButton.widthAnchor)
        ])
        
        trendingAnimeCollectionView?.dataSource = self
        trendingAnimeCollectionView?.delegate = self
        trendingAnimeCollectionView?.register(SearchingAnimeCollectionViewCell.self, forCellWithReuseIdentifier: "searchCell")
        if let seasonUpperCase = PickerData.seasonPickerOption.first?.uppercased(), let yearStr = PickerData.yearPickerOption.last?.description {
            AnimeDataFetcher.shared.fetchAnimeBySearch(year: yearStr, season: seasonUpperCase)
        }
        
        let formatMenuActions = AnimeFormat.allCases.map({
            return UIAction(title: $0.stringValue) { action in
                print(action.title)
                self.formatButton.setTitle(action.title, for: .normal)
            }
        })
        formatButton.menu = UIMenu(title: "format", children: formatMenuActions)
        formatButton.setTitle("select", for: .normal)
        
        genresButton.setTitle("select", for: .normal)
        AnimeDataFetcher.shared.loadEssentialData { essentialData in
            self.genres = essentialData.GenreCollection
            let genresMenuActions = self.genres.map({
                return UIAction(title: $0) { action in
                    self.genresButton.setTitle(action.title, for: .normal)
                }
            })
            DispatchQueue.main.async {
                self.genresButton.menu = UIMenu(title: "Genres", children: genresMenuActions)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    deinit {
        print("SearchingPageViewController deinit")
    }
    
    @objc func seasonButtonTap(sender: UIButton) {
        seasonTableView.isHidden = false
    }
    
    @objc func yearButtonTap(sender: UIButton) {
        yearTableView.isHidden = false
    }
    
//    func fetchImages() {
//        let urls = Array(repeating: "https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx107372-4N3N0xVgI8go.jpg", count: 50)
//
//        for (index, urlString) in urls.enumerated() {
//            print(index, urlString)
//            downloadImage(url: urlString, index: index)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension SearchPageViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return PickerData.yearPickerOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(PickerData.yearPickerOption[row])"
    }
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension SearchPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        if tableView == seasonTableView {
            numberOfRowsInSection = PickerData.seasonPickerOption.count
        } else if tableView == yearTableView {
            numberOfRowsInSection = PickerData.yearPickerOption.count
        }
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if tableView == seasonTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell", for: indexPath)
            cell.textLabel?.text = PickerData.seasonPickerOption[indexPath.row]
            return cell
        } else if tableView == yearTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "yearCell", for: indexPath)
            cell.textLabel?.text = "\(PickerData.yearPickerOption[indexPath.row])"
            return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == seasonTableView {
            seasonButton.setTitle(PickerData.seasonPickerOption[indexPath.row], for: .normal)
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.isHidden = true
            let seasonUpperCase = PickerData.seasonPickerOption[indexPath.row].uppercased()
            if let yearStr = yearButton.titleLabel?.text?.description {
                AnimeDataFetcher.shared.fetchAnimeBySearch(year: yearStr, season: seasonUpperCase)
            }
        } else if tableView == yearTableView {
            yearButton.setTitle(PickerData.yearPickerOption[indexPath.row].description, for: .normal)
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.isHidden = true
            let yearStr = PickerData.yearPickerOption[indexPath.row].description
            if let seasonUpperCase = seasonButton.titleLabel?.text?.uppercased() {
                AnimeDataFetcher.shared.fetchAnimeBySearch(year: yearStr, season: seasonUpperCase)
            }
        }
        
    }
}
// MARK: - UICollectionViewDataSource, UICollectionDelegate
extension SearchPageViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return animeData?.data.Page.media.count ?? 50
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! SearchingAnimeCollectionViewCell
        if let animeAllData = self.animeData {
            let animeOneData = animeAllData.data.Page.media[indexPath.item]
            cell.setup(title: animeOneData.title.native, imageURL: animeOneData.coverImage.extraLarge)
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
            AnimeDataFetcher.shared.fetchAnimeByID(id: animeID)
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
