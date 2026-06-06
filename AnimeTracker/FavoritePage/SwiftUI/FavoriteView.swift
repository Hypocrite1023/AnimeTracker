//
//  FavoriteView.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2025/9/10.
//

import SwiftUI
import Kingfisher
import Combine

struct FavoriteView: View {
    
    @StateObject private var viewModel: FavoriteViewViewModel = FavoriteViewViewModel()
    let animeTapCallBackSubject: PassthroughSubject<Int, Never>?
    
    var body: some View {
        VStack(spacing: 10) {
            // Filter Header (full width to prevent text truncation)
            Picker("Filter", selection: $viewModel.selectedStatusFilter) {
                Text("All").tag(nil as UserAnimeStatus?)
                ForEach(UserAnimeStatus.allCases, id: \.self) { status in
                    Text(status.localizedTitle).tag(status as UserAnimeStatus?)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Sort Header (styled row)
            HStack {
                Spacer()
                Menu {
                    Picker("Sort By", selection: $viewModel.selectedSortOption) {
                        ForEach(FavoriteSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("Sort: \(viewModel.selectedSortOption.rawValue)")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                generateFavoriteAnimeList(animes: viewModel.favorites)
            }
            .padding(.horizontal)
            .scrollIndicators(.hidden, axes: .vertical)
        }
        .onAppear {
            LocalRecordManager.shared.resetFavoritePagination()
            viewModel.shouldReloadData.send(())
        }
    }
}

private extension FavoriteView {
    @ViewBuilder
    func generateFavoriteAnimeList(animes: [Response.AnimeEssentialData]) -> some View {
        LazyVStack {
            if animes.isEmpty {
                VStack(spacing: 12) {
                    Spacer().frame(height: 40)
                    Image(systemName: "star.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No records found")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            } else {
                ForEach(animes, id: \.id) { airingAnime in
                    if let animeUserPreference = Binding($viewModel.animeStatusDict[airingAnime.id]) {
                        FavoriteAnimeCard(
                            animeInfo: airingAnime,
                            animeUserPreference: animeUserPreference,
                            userStatus: viewModel.animeTimeDict[airingAnime.id]?.userStatus,
                            animeTapCallBackSubject: animeTapCallBackSubject,
                            animeConfigNotificationSubject: viewModel.shouldConfigAnimeNotification,
                            updateUserStatus: { newStatus in
                                withAnimation(.spring) {
                                    viewModel.updateUserStatus(animeID: airingAnime.id, newStatus: newStatus)
                                }
                            },
                            onFavoriteToggle: {
                                withAnimation(.spring) {
                                    viewModel.toggleFavorite(animeID: airingAnime.id)
                                }
                            }
                        )
                        Divider()
                            .onAppear {
                                if airingAnime.id == animes.last?.id {
                                    viewModel.shouldLoadMoreData.send(())
                                }
                            }
                    }
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: UserAnimeStatus
    
    var body: some View {
        Text(status.localizedTitle)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundColor(badgeColor)
            .background(
                Capsule()
                    .stroke(badgeColor, lineWidth: 1)
            )
    }
    
    private var badgeColor: Color {
        switch status {
        case .planToWatch: return .yellow
        case .watching: return .green
        case .completed: return .blue
        }
    }
}

struct FavoriteAnimeCard: View {
    let animeInfo: Response.AnimeEssentialData
    @Binding var animeUserPreference: (isFavorite: Bool, isNotify: Bool)
    let userStatus: UserAnimeStatus?
    let animeTapCallBackSubject: PassthroughSubject<Int, Never>?
    let animeConfigNotificationSubject: PassthroughSubject<Int, Never>?
    let updateUserStatus: ((UserAnimeStatus) -> Void)?
    let onFavoriteToggle: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            KFImage(URL(string: animeInfo.coverImage?.extraLarge ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 2)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(animeInfo.title.native)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    if let userStatus = userStatus {
                        Menu {
                            ForEach(UserAnimeStatus.allCases, id: \.self) { status in
                                Button(status.localizedTitle) {
                                    updateUserStatus?(status)
                                }
                            }
                        } label: {
                            StatusBadge(status: userStatus)
                        }
                    }
                    
                    if let score = animeInfo.averageScore {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                               .font(.caption2)
                               .foregroundColor(.yellow)
                            Text("\(score)")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    onFavoriteToggle?()
                }) {
                    Image(systemName: animeUserPreference.isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
                .buttonStyle(.plain)
                
                if animeInfo.statusInfo == .airing {
                    Button(action: {
                        animeConfigNotificationSubject?.send(animeInfo.id)
                    }) {
                        Image(systemName: animeUserPreference.isNotify ? "bell.fill" : "bell")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            animeTapCallBackSubject?.send(animeInfo.id)
        }
    }
}
