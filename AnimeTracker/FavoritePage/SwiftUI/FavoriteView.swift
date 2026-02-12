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
        ScrollView {
            generateFavoriteAnimeList(animes: viewModel.favorites)
        }
        .padding(.horizontal)
        .scrollIndicators(.hidden, axes: .vertical)
        .onAppear {
            FirebaseManager.shared.resetFavoritePagination()
            viewModel.shouldReloadData.send(())
        }
    }
}

private extension FavoriteView {
    @ViewBuilder
    func generateFavoriteAnimeList(animes: [Response.AnimeEssentialData]) -> some View {
        LazyVStack {
            if animes.isEmpty {
                Text("No data...")
            } else{
                ForEach(animes, id: \.id) { airingAnime in
                    if let animeUserPreference = Binding($viewModel.animeStatusDict[airingAnime.id]) {
                        FavoriteAnimeCard(animeInfo: airingAnime, animeUserPreference: animeUserPreference, animeTapCallBackSubject: animeTapCallBackSubject, animeConfigNotificationSubject: viewModel.shouldConfigAnimeNotification)
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

struct ExpandableTitleView<Content: View>: View {
    let sectionTitle: String
    let sectionType: Response.AnimeStatus
    @Binding var currentExpandedSection: Response.AnimeStatus
    @ViewBuilder let expandableContent: Content
    var body: some View {
        HStack {
            Text(sectionTitle)
                .bold()
            Spacer()
            if sectionType == currentExpandedSection {
                Image(systemName: "chevron.up")
            } else {
                Image(systemName: "chevron.down")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring) {
                currentExpandedSection = sectionType
            }
        }
        Divider()
        if sectionType == currentExpandedSection {
            expandableContent
        }
    }
}

struct FavoriteAnimeCard: View {
    let animeInfo: Response.AnimeEssentialData
    @Binding var animeUserPreference: (isFavorite: Bool, isNotify: Bool)
    let animeTapCallBackSubject: PassthroughSubject<Int, Never>?
    let animeConfigNotificationSubject: PassthroughSubject<Int, Never>?
    
    var body: some View {
        HStack {
            KFImage(URL(string: animeInfo.coverImage?.extraLarge ?? ""))
                .resizable()
                .scaledToFit()
                .frame(width: 75)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Spacer()
                Text(animeInfo.title.native)
                    .multilineTextAlignment(.leading)
                    .italic()
                    .padding(.leading, 20)
                Spacer()
                HStack {
                    Spacer()
                    Button("", systemImage: animeUserPreference.isFavorite ? "star.fill" : "star", action: {
                        animeUserPreference.isFavorite.toggle()
                    })
                    .tint(.yellow)
                    if animeInfo.statusInfo == .airing {
                        Button("", systemImage: animeUserPreference.isNotify ? "bell.fill" : "bell", action: {
                            animeConfigNotificationSubject?.send(animeInfo.id)
                        })
                        .tint(.blue)
                    }
                }
            }
        }
        .frame(height: 100)
        .contentShape(Rectangle())
        .onTapGesture {
            animeTapCallBackSubject?.send(animeInfo.id)
        }
    }
}

#Preview {
    FavoriteView(animeTapCallBackSubject: nil)
}
