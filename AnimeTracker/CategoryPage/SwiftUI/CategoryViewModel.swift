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
    let items: [AnimeCellItem]
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id && lhs.category == rhs.category && lhs.items == rhs.items
    }
}

class CategoryViewModel: ObservableObject {
    // MARK: - data property
    @Published var categories: [Category] = []
    @Published private var genres: [String] = []
    private var cancellables: Set<AnyCancellable> = []
    // MARK: - input
    let didSelectAnime: PassthroughSubject<Int, Never> = .init()
    let shouldShowAlert: PassthroughSubject<String, Never> = .init()
    // MARK: - output
    var showAnimeDetail: AnyPublisher<Int, Never> = .empty
    var showAlert: AnyPublisher<String, Never> = .empty
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
                AnimeDataFetcher.shared.fetchAnimeByCategory(genere: genres)
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.shouldShowAlert.send(error.localizedDescription)
                }
            } receiveValue: { result in
                AnimeDataFetcher.shared.isFetchingData = false
                var newCategories: [Category] = []
                for (_, (category, animes)) in result.data.enumerated() {
                    newCategories.append(Category(category: category, items: animes.media.map { AnimeCellItem(animeID: $0.id, animeName: $0.title.native ?? "", animeThumbnailURL: URL(string: $0.coverImage.large)) }))
                }
                self.categories = newCategories
                print("✅ categories updated: \(self.categories.count)")
            }
            .store(in: &cancellables)
        
        showAlert = shouldShowAlert.eraseToAnyPublisher()
        
        showAnimeDetail = didSelectAnime.eraseToAnyPublisher()
    }
}
