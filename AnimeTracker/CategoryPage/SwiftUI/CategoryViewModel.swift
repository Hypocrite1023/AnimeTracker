//
//  CategoryViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/7.
//

import Foundation
import Combine

struct AnimeCellItem: Identifiable, Equatable {
    let id = UUID()
    let animeID: Int
    let animeName: String
    let animeThumbnailURL: URL?
}

struct Category: Identifiable, Equatable {
    let id = UUID()
    let category: String
    var items: [AnimeCellItem]
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id && lhs.category == rhs.category && lhs.items == rhs.items
    }
    
    enum sortBy: CaseIterable {
        
        case popularity
        case rating
        case newest
        case trending
        
        var apiParameter: String {
            switch self {
            case .popularity:
                return "POPULARITY_DESC"
            case .rating:
                return "SCORE_DESC"
            case .newest:
                return "START_DATE_DESC"
            case .trending:
                return "TRENDING_DESC"
            }
        }
        
        var title: String {
            switch self {
            case .popularity:
                return "POPULARITY"
            case .rating:
                return "SCORE"
            case .newest:
                return "NEWEST"
            case .trending:
                return "TRENDING"
            }
        }
    }
}

class CategoryViewModel: ObservableObject {
    // MARK: - data property
    @Published var categories: [Category] = []
    @Published var eachCategorySortBy: [UUID: Category.sortBy] = [:]
    @Published private var genres: [String] = []
    private var initializeDone: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - input
    let didSelectAnime: PassthroughSubject<Int, Never> = .init()
    let shouldShowAlert: PassthroughSubject<String, Never> = .init()
    let shouldReloadSpecifyCategory: PassthroughSubject<(categoryKey: UUID, sortBy: Category.sortBy), Never> = .init()
    let shouldLoadMoreSpecifyCategory: PassthroughSubject<UUID, Never> = .init()
    // MARK: - output
    var showAnimeDetail: AnyPublisher<Int, Never> = .empty
    var showAlert: AnyPublisher<String, Never> = .empty
    let categoryScrollViewScrollToLeading: PassthroughSubject<UUID, Never> = .init()
    init() {
        AnimeDataFetcher.shared.loadAnimeSearchingEssentialData()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.shouldShowAlert.send(error.localizedDescription)
                }
            } receiveValue: { genres in
                self.genres = genres.genreCollection
                AnimeDataFetcher.shared.isFetchingData = false
            }
            .store(in: &cancellables)
        
        $genres
            .dropFirst()
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .flatMap { genres in
                AnimeDataFetcher.shared.fetchAnimeByCategory(genere: genres, sortBy: Category.sortBy.popularity.apiParameter, page: 1)
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.shouldShowAlert.send(error.localizedDescription)
                }
            } receiveValue: { [weak self] result in
                guard let self = self else { return }
                AnimeDataFetcher.shared.isFetchingData = false
                var newCategories: [Category] = []
                for (_, (category, animes)) in result.data.enumerated() {
                    let newCategory: Category = Category(category: category, items: animes.media.map { AnimeCellItem(animeID: $0.id, animeName: $0.title.native ?? "", animeThumbnailURL: URL(string: $0.coverImage.large)) })
                    newCategories.append(newCategory)
                    self.eachCategorySortBy[newCategory.id] = .popularity
                }
                self.categories = newCategories
                self.initializeDone = true
                print("✅ categories updated: \(self.categories.count)")
            }
            .store(in: &cancellables)
        
        $eachCategorySortBy
            .removeDuplicates()
            .scan(([:], [:])) { previous, current in
                (previous.1, current)
            }
            .filter { [weak self] _ in self?.initializeDone ?? false }
            .sink { [weak self] previous, current in
                guard let self = self else { return }
                let old = previous
                let new = current
                let changed = new.filter { key, value in
                    old[key] != value
                }
                for (key, value) in changed {
                    print("🔁 Updated key: \(key), new value: \(value)")
                    self.shouldReloadSpecifyCategory.send((key, value))
                    
                }
            }
            .store(in: &cancellables)
        
        shouldReloadSpecifyCategory
            .compactMap { uuid, sortBy -> (UUID, String, Category.sortBy)? in
                guard let category = self.categories.first(where: { $0.id == uuid })?.category else { return nil }
                return (uuid, category, sortBy)
            }
            .flatMap { uuid, category, sortBy -> AnyPublisher<(UUID, AnimeCategoryResult), Error> in
                AnimeDataFetcher.shared.fetchAnimeByCategory(genere: [category], sortBy: sortBy.apiParameter, page: 1)
                    .map { result in (uuid, result)}
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.shouldShowAlert.send(error.localizedDescription)
                }
            } receiveValue: { result in
                for (_, (_, animes)) in result.1.data.enumerated() {
                    guard let index = self.categories.firstIndex(where: { $0.id == result.0 }) else { continue }
                    self.categories[index].items = animes.media.map { AnimeCellItem(animeID: $0.id, animeName: $0.title.native ?? "", animeThumbnailURL: URL(string: $0.coverImage.large)) }
                    self.categoryScrollViewScrollToLeading.send(result.0)
                }
            }
            .store(in: &cancellables)
        
        shouldLoadMoreSpecifyCategory
            .compactMap { uuid -> (UUID, String, Category.sortBy, Int)? in
                print("should load more")
                guard let category = self.categories.first(where: { $0.id == uuid })?.category, let sortBy = self.eachCategorySortBy[uuid], let animeCount = self.categories.first(where: { $0.id == uuid })?.items.count else { return nil }
                return (uuid, category, sortBy, animeCount / 20 + 1)
            }
            .flatMap { uuid, category, sortBy, page -> AnyPublisher<(UUID, AnimeCategoryResult), Error> in
                AnimeDataFetcher.shared.fetchAnimeByCategory(genere: [category], sortBy: sortBy.apiParameter, page: page)
                    .map { result in (uuid, result)}
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.shouldShowAlert.send(error.localizedDescription)
                }
            } receiveValue: { result in
                for (_, (_, animes)) in result.1.data.enumerated() {
                    guard let index = self.categories.firstIndex(where: { $0.id == result.0 }) else { continue }
                    self.categories[index].items.append(contentsOf: animes.media.map { AnimeCellItem(animeID: $0.id, animeName: $0.title.native ?? "", animeThumbnailURL: URL(string: $0.coverImage.large)) })
                }
            }
            .store(in: &cancellables)
            
        
        showAlert = shouldShowAlert.eraseToAnyPublisher()
        
        showAnimeDetail = didSelectAnime.eraseToAnyPublisher()
    }
}
