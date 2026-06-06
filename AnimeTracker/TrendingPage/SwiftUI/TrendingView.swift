//
//  TrendingView.swift
//  AnimeTracker
//
//  Created by Antigravity on 2026/6/6.
//

import SwiftUI
import Kingfisher
import SkeletonUI
import Combine

struct TrendingView: View {
    @ObservedObject var viewModel: TrendingPageViewModel
    var onAnimeTap: (Int) -> Void
    var onScroll: ((CGFloat) -> Void)?
    
    // Popup Menu State
    @State private var selectedAnimeForMenu: Response.AnimeEssentialData?
    @State private var isFavoriteForMenu: Bool = false
    @State private var isNotifyForMenu: Bool = false
    @State private var isLoadingMenuRecord: Bool = false
    @State private var menuCancellable: AnyCancellable?
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    if viewModel.animeTrendingData == nil {
                        // Skeleton views during initial loading
                        TrendingSkeletonView()
                            .padding(.top, 16)
                    } else if let mediaList = viewModel.animeTrendingData?.data.page.media {
                        ForEach(mediaList, id: \.id) { anime in
                            TrendingAnimeCard(
                                anime: anime,
                                onTap: {
                                    onAnimeTap(anime.id)
                                },
                                onLongPress: {
                                    presentPopupMenu(for: anime)
                                }
                            )
                            .onAppear {
                                if anime.id == mediaList.last?.id {
                                    viewModel.shouldLoadMoreTrendingData.send(())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named("scroll")).minY
                            )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                onScroll?(value)
            }
            .refreshable {
                await withCheckedContinuation { continuation in
                    var cancellable: AnyCancellable?
                    cancellable = viewModel.$animeTrendingData
                        .dropFirst()
                        .first()
                        .sink { _ in
                            continuation.resume()
                            cancellable?.cancel()
                        }
                    viewModel.shouldRefreshTrendingData.send(())
                }
            }
            
            // Pop-up Long Press Detail Menu
            if let selectedAnime = selectedAnimeForMenu {
                ZStack {
                    // Blurred Backdrop
                    Color.black.opacity(0.4)
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissMenu()
                        }
                    
                    // Detail Modal Card
                    VStack(spacing: 20) {
                        // Poster Image
                        KFImage(URL(string: selectedAnime.coverImage?.extraLarge ?? selectedAnime.coverImage?.large ?? ""))
                            .placeholder {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.15))
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 200)
                            .cornerRadius(16)
                            .clipped()
                            .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 5)
                        
                        // Title
                        Text(selectedAnime.title.native ?? selectedAnime.title.english ?? selectedAnime.title.romaji ?? "")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal)
                        
                        // Action Buttons
                        if isLoadingMenuRecord {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .frame(height: 72)
                        } else {
                            HStack(spacing: 24) {
                                // Favorite Button
                                Button(action: {
                                    toggleFavorite(for: selectedAnime)
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: isFavoriteForMenu ? "star.fill" : "star")
                                            .font(.title2)
                                        Text(isFavoriteForMenu ? "Favorited" : "Favorite")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                    }
                                    .foregroundColor(isFavoriteForMenu ? .white : .primary)
                                    .frame(width: 80, height: 72)
                                    .background(isFavoriteForMenu ? Color.yellow : Color.primary.opacity(0.08))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                
                                // Notification Button (Only if releasing)
                                if selectedAnime.status == "RELEASING" {
                                    Button(action: {
                                        toggleNotification(for: selectedAnime)
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: isNotifyForMenu ? "bell.fill" : "bell")
                                                .font(.title2)
                                        Text(isNotifyForMenu ? "Notifying" : "Notify")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                        }
                                        .foregroundColor(isNotifyForMenu ? .white : .primary)
                                        .frame(width: 80, height: 72)
                                        .background(isNotifyForMenu ? Color.blue : Color.primary.opacity(0.08))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(ScaleButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(uiColor: .systemBackground))
                            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                    )
                    .frame(maxWidth: 280)
                }
            }
        }
    }
    
    // MARK: - Menu Actions
    private func presentPopupMenu(for anime: Response.AnimeEssentialData) {
        selectedAnimeForMenu = anime
        isLoadingMenuRecord = true
        
        menuCancellable = viewModel.getLocalRecord(for: anime.id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                isLoadingMenuRecord = false
            }, receiveValue: { record in
                isFavoriteForMenu = record?.isFavorite ?? false
                isNotifyForMenu = record?.isNotify ?? false
                isLoadingMenuRecord = false
            })
    }
    
    private func dismissMenu() {
        menuCancellable?.cancel()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selectedAnimeForMenu = nil
        }
    }
    
    private func toggleFavorite(for anime: Response.AnimeEssentialData) {
        viewModel.toggleFavorite(
            animeID: anime.id,
            isNotify: isNotifyForMenu,
            status: anime.status ?? "FINISHED",
            currentFavorite: isFavoriteForMenu
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }, receiveValue: { newFavorite in
            isFavoriteForMenu = newFavorite
        })
        .store(in: &viewModel.cancellables)
    }
    
    private func toggleNotification(for anime: Response.AnimeEssentialData) {
        viewModel.toggleNotification(
            animeID: anime.id,
            isFavorite: isFavoriteForMenu,
            status: anime.status ?? "FINISHED",
            currentNotify: isNotifyForMenu
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }, receiveValue: { newNotify in
            isNotifyForMenu = newNotify
        })
        .store(in: &viewModel.cancellables)
    }
}

// MARK: - Subviews

struct TrendingAnimeCard: View {
    let anime: Response.AnimeEssentialData
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center, spacing: 6) {
                // Poster
                KFImage(URL(string: anime.coverImage?.extraLarge ?? anime.coverImage?.large ?? ""))
                    .placeholder {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.primary.opacity(0.06))
                            .aspectRatio(125/175, contentMode: .fit)
                    }
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(125/175, contentMode: .fit)
                    .cornerRadius(12)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                
                // Name
                Text(anime.title.native ?? anime.title.english ?? anime.title.romaji ?? "")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .frame(height: 32, alignment: .top)
                    .padding(.horizontal, 2)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    onLongPress()
                }
        )
    }
}

struct TrendingSkeletonView: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<9) { _ in
                VStack(spacing: 8) {
                    Text("")
                        .skeleton(with: true, size: CGSize(width: 105, height: 147), shape: .rectangle)
                        .cornerRadius(12)
                    
                    Text("")
                        .skeleton(with: true, size: CGSize(width: 80, height: 14), shape: .rectangle)
                        .cornerRadius(4)
                }
            }
        }
    }
}

// MARK: - PreferenceKey for Scroll Offset

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
