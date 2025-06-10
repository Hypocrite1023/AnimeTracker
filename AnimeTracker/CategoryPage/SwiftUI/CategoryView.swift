//
//  CategoryView.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/7.
//

import SwiftUI
import Kingfisher

struct CategoryView: View {
    @StateObject private var vm: CategoryViewModel = CategoryViewModel()
    var onAnimeTap: ((Int) -> Void)?
    
    @State private var previousOffset: CGFloat = 0
    var onScrollDirectionChange: ((ScrollDirection) -> Void)?
    
    enum ScrollDirection {
        case up, down
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(vm.categories) { category in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(category.category.capitalized.replacingOccurrences(of: "_", with: " "))
                                .bold()
                                .font(.title2)
                                .padding(.leading)
                            Spacer()
                            CategoryButton(categoryUUID: category.id, selectedCategorySortBy: vm.eachCategorySortBy[category.id] ?? .popularity, categoryOnChange: { uuid, categorySort in
                                self.vm.eachCategorySortBy[uuid] = categorySort
                            })
                                .padding(.trailing)
                        }
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(Array(category.items.enumerated()), id: \.element.id) { (index, anime) in
                                        animeCard(animeID: anime.animeID, animeTitle: anime.animeName, animeImage: anime.animeThumbnailURL, onTap: {
                                            self.vm.didSelectAnime.send($0)
                                        })
                                        .id("\(category.id.uuidString)-\(index)") // 確保每個 category 的 scroll id 是唯一的
                                        .onAppear {
                                            if anime == category.items[category.items.count - 3] {
                                                self.vm.shouldLoadMoreSpecifyCategory.send(category.id)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                
                            }
                            .onReceive(vm.categoryScrollViewScrollToLeading) { uuid in
                                if category.id == uuid {
                                    withAnimation {
                                        proxy.scrollTo("\(uuid.uuidString)-0", anchor: .leading)
                                    }
                                }
                            }
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
}

struct animeCard: View {
    let animeID: Int
    let animeTitle: String
    let animeImage: URL?
    let onTap: (Int) -> Void
    var body: some View {
        VStack(spacing: 8) {
            // 如果你之後要載入網路圖片，可以改用 AsyncImage
            KFImage(animeImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 200)
                .cornerRadius(10)
                .clipped()
            
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
            onTap(animeID)
//            self.vm.didSelectAnime.send(animeID)
        }
    }
}

struct CategoryButton: View {
    let categoryUUID: UUID
    var selectedCategorySortBy: Category.sortBy
    let categoryOnChange: (UUID, Category.sortBy) -> Void
    
    var body: some View {
        Menu {
            ForEach(Category.sortBy.allCases, id: \.self) { category in
                Button(action: {
                    // change the category sort way to the eachcategorysort accroding to category uuid
                    categoryOnChange(categoryUUID, category)
                }) {
                    Text(category.title)
                }
            }
        } label: {
            Text(selectedCategorySortBy.title)
                .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}
