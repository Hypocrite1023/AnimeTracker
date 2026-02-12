//
//  TimelineView.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/17.
//

import SwiftUI
import Combine
import Kingfisher

struct TimelineView: View {
    
    @StateObject private var viewModel: TimelineViewViewModel = .init()
    
    var body: some View {
        ScrollView {
            ForEach(viewModel.animeLists, id: \.id) { airingAnime in
                TimelineAnimeCard(animeInfo: airingAnime, animeTapCallBackSubject: nil, passedSeconds: viewModel.passedSeconds)
                Divider()
            }
        }
        .padding(.horizontal)
    }
}

struct TimelineAnimeCard: View {
    let animeInfo: Response.AnimeTimelineData
    let animeTapCallBackSubject: PassthroughSubject<Int, Never>?
    let passedSeconds: Int
    
    var body: some View {
        HStack {
            KFImage(URL(string: animeInfo.coverImage?.extraLarge ?? ""))
                .resizable()
                .scaledToFit()
                .frame(width: 75)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading) {
                Spacer()
                Text(animeInfo.title.native ?? "")
                    .multilineTextAlignment(.leading)
                    .italic()
                    .padding(.leading, 20)
                Spacer()
            }
            Spacer()
            VStack(alignment: .trailing) {
                if let timeUntilAiring = animeInfo.nextAiringEpisode?.timeUntilAiring, let ep = animeInfo.nextAiringEpisode?.episode {
                    Text("Time to airing ep.\(ep):")
                        .font(.system(size: 8))
                    Text((timeUntilAiring - passedSeconds).makeTimeString())
                        .font(.system(size: 8))
                } else {
                    Text("Nan")
                }
            }
            .frame(width: 100)
        }
        .frame(height: 100)
        .contentShape(Rectangle())
        .onTapGesture {
            animeTapCallBackSubject?.send(animeInfo.id)
        }
    }
}

#Preview {
    TimelineView()
}
