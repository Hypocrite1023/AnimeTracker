//
//  CategoryView.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/7.
//

import SwiftUI

struct CategoryView: View {
    @StateObject private var vm: CategoryViewModel = CategoryViewModel()
    var onAnimeTap: ((Int) -> Void)?
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(vm.categories) { category in
                    VStack(alignment: .leading) {
                        Text(category.category.capitalized.replacingOccurrences(of: "_", with: " "))
                            .bold()
                            .font(.title2)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(category.items) { anime in
                                    animeCard(animeID: anime.animeID, animeTitle: anime.animeName, animeImage: anime.animeThumbnailURL)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .onReceive(vm.showAnimeDetail) { animeID in
            onAnimeTap?(animeID)
        }
    }
    
    @ViewBuilder
    func animeCard(animeID: Int, animeTitle: String, animeImage: URL?) -> some View {
        VStack(spacing: 8) {
            // 如果你之後要載入網路圖片，可以改用 AsyncImage
            AsyncImage(url: animeImage) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 150, height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 200)
                        .clipped()
                case .failure:
                    Image(systemName: "xmark.octagon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 200)
                        .foregroundColor(.red)
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(10)

            Text(animeTitle)
                .frame(width: 150, height: 40)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .font(.body)
                .minimumScaleFactor(0.7) // 縮小文字防止截斷
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
        }
        .onTapGesture {
            self.vm.didSelectAnime.send(animeID)
        }
    }
}

#Preview {
    CategoryView()
}
