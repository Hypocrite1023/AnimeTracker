//
//  CategoryView.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/7.
//

import SwiftUI
import Kingfisher
import SkeletonUI

struct CategoryView: View {
    @StateObject private var vm: CategoryViewModel = CategoryViewModel()
    var onAnimeTap: ((Int) -> Void)?
    
    @State private var previousOffset: CGFloat = 0
    var onScrollDirectionChange: ((ScrollDirection) -> Void)?
    
    enum ScrollDirection {
        case up, down
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            VStack(spacing: 0) {
                // Top Scrollable Genre Quick-Jump Bar
                if !vm.isLoadingCategoryData && !vm.categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(vm.categories) { category in
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        scrollProxy.scrollTo(category.id.uuidString, anchor: .top)
                                    }
                                }) {
                                    Text(category.category.capitalized.replacingOccurrences(of: "_", with: " "))
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .foregroundColor(.primary)
                                        .background(
                                            Capsule()
                                                .fill(Color.primary.opacity(0.08))
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .background(Color(uiColor: .systemBackground).opacity(0.85))
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                }
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        if vm.isLoadingCategoryData {
                            // Display skeleton views while loading
                            ForEach(0..<3) { _ in
                                CategorySkeletonView()
                            }
                        } else {
                            // Spotlight Banner
                            if let spotlight = vm.categories.first?.items.first {
                                SpotlightBanner(anime: spotlight, onTap: {
                                    vm.didSelectAnime.send(spotlight.animeID)
                                })
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            // Category list
                            ForEach(vm.categories) { category in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        // Left Accent Colored Bar + Category Title
                                        HStack(spacing: 8) {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.blue)
                                                .frame(width: 4, height: 20)
                                            
                                            Text(category.category.capitalized.replacingOccurrences(of: "_", with: " "))
                                                .font(.title3)
                                                .fontWeight(.bold)
                                        }
                                        .padding(.leading)
                                        
                                        Spacer()
                                        
                                        CategoryButton(categoryUUID: category.id, selectedCategorySortBy: vm.eachCategorySortBy[category.id] ?? .popularity, categoryOnChange: { uuid, categorySort in
                                            self.vm.eachCategorySortBy[uuid] = categorySort
                                        })
                                        .padding(.trailing)
                                    }
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        LazyHStack(spacing: 12) {
                                            ForEach(Array(category.items.enumerated()), id: \.element.id) { (index, anime) in
                                                AnimePosterCard(animeID: anime.animeID, animeTitle: anime.animeName, animeImage: anime.animeThumbnailURL, onTap: { 
                                                    self.vm.didSelectAnime.send($0)
                                                })
                                                .onAppear {
                                                    if index == max(0, category.items.count - 3) {
                                                        self.vm.shouldLoadMoreSpecifyCategory.send(category.id)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 4)
                                    }
                                    .id("\(category.id.uuidString)-\(vm.eachCategorySortBy[category.id]?.title ?? "POPULARITY")")
                                }
                                .id(category.id.uuidString) // Anchor for vertical scrollProxy
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .onReceive(vm.showAnimeDetail) { animeID in
            onAnimeTap?(animeID)
        }
    }
}

// --- START: Skeleton View Definitions ---

struct CategorySkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder for category title
            Text("")
                .skeleton(with: true, size: CGSize(width: 120, height: 24), shape: .rectangle)
                .cornerRadius(4)
                .padding(.horizontal)

            // Placeholder for horizontal anime cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<5) { _ in
                        VStack(spacing: 8) {
                            Text("")
                                .skeleton(with: true, size: CGSize(width: 125, height: 175), shape: .rectangle)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 4)
    }
}

// --- END: Skeleton View Definitions ---

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct AnimePosterCard: View {
    let animeID: Int
    let animeTitle: String
    let animeImage: URL?
    let onTap: (Int) -> Void
    
    var body: some View {
        Button(action: {
            onTap(animeID)
        }) {
            ZStack(alignment: .bottomLeading) {
                // Poster Image
                KFImage(animeImage)
                    .placeholder {
                        Color.gray.opacity(0.15)
                            .cornerRadius(12)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 125, height: 175)
                    .cornerRadius(12)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                
                // Bottom Gradient Overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.6),
                        Color.black.opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(12)
                
                // Text Label
                Text(animeTitle)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                    .shadow(radius: 2)
            }
            .frame(width: 125, height: 175)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct SpotlightBanner: View {
    let anime: AnimeCellItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Banner Image (large)
                KFImage(anime.animeThumbnailURL)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 190)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                // Dark Overlay
                LinearGradient(
                    colors: [Color.black.opacity(0.2), Color.black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(16)
                
                // Content Overlay
                VStack(alignment: .leading, spacing: 6) {
                    // Premium Tag
                    HStack {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("SPOTLIGHT")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(.yellow)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Capsule())
                    
                    Text(anime.animeName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("Explore details, ratings, and active discussions.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(16)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct CategoryButton: View {
    let categoryUUID: UUID
    var selectedCategorySortBy: Category.sortBy
    let categoryOnChange: (UUID, Category.sortBy) -> Void
    
    var body: some View {
        Menu {
            ForEach(Category.sortBy.allCases, id: \.self) { sortBy in
                Button(action: {
                    categoryOnChange(categoryUUID, sortBy)
                }) {
                    Text(sortBy.title)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedCategorySortBy.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Image(systemName: "chevron.down")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .clipShape(Capsule())
        }
    }
}

