//
//  SearchPageViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/17.
//

import Foundation
import Combine

class SearchPageViewModel {
    @Published var searchingResult: Response.AnimeSearchingResult? {
        didSet {
//            print(searchingResult)
        }
    }
    @Published var currentPage: Int = 1
    var lastTimeFetchData: Date?
    var genres: [String] = []
    
    var refreshing: Bool = false
    
    @Published var title: String = ""
    @Published var selectedGenreSet: Set<String> = []
    @Published var selectedFormatSet: Set<String> = []
    @Published var selectedSort: String = ""
    @Published var selectedAiringStatusSet: Set<String> = []
    @Published var selectedStreamingOnSet: Set<String> = []
    @Published var selectedCountry: String = ""
    @Published var selectedSourceSet: Set<String> = []
    @Published var showDoujin: Bool = false
    @Published var selectedSeasonYear: Int?
    @Published var selectedSeason: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $title
            .combineLatest($selectedGenreSet)
            .combineLatest($selectedFormatSet)
            .combineLatest($selectedSort)
            .combineLatest($selectedAiringStatusSet)
            .combineLatest($selectedStreamingOnSet)
            .combineLatest($selectedCountry)
            .combineLatest($selectedSourceSet)
            .combineLatest($showDoujin)
            .combineLatest($selectedSeasonYear)
            .combineLatest($selectedSeason)
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.currentPage = 1
//                self.refreshing = true
//                self.searchAnime()
            }
            .store(in: &cancellables)
        $currentPage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.searchAnime()
            }
            .store(in: &cancellables)
    }
    
    func searchAnime() {
        lastTimeFetchData = .now
        AnimeDataFetcher.shared.searchAnime(title: title, genres: selectedGenreSet.map({$0}), format: selectedFormatSet.map({$0}), sort: selectedSort, airingStatus: selectedAiringStatusSet.map({$0}), streamingOn: selectedStreamingOnSet.map({$0}), country: selectedCountry, sourceMaterial: selectedSourceSet.map({$0}), doujin: showDoujin, year: selectedSeasonYear, season: selectedSeason, page: currentPage)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                
            } receiveValue: { searchingResult in
//                print(searchingResult)
                if searchingResult.data.Page.pageInfo.currentPage == 1 {
                    self.refreshing = true
                    self.searchingResult = searchingResult
                } else {
                    self.refreshing = false
                    self.searchingResult?.data.Page.media.append(contentsOf: searchingResult.data.Page.media)
                }
                self.searchingResult?.data.Page.pageInfo.hasNextPage = searchingResult.data.Page.pageInfo.hasNextPage
                AnimeDataFetcher.shared.isFetchingData = false
            }
            .store(in: &cancellables)
    }
}

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
