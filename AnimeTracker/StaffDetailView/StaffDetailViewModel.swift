//
//  StaffDetailViewModel.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/4/24.
//

import Foundation
import Combine

class StaffDetailViewModel {
    @Published var staffData: Response.StaffDetailData.StaffData.Staff?
    @Published var staffAnimeData: [Response.StaffDetailData.StaffData.Staff.StaffMedia.Edge] = []
    @Published var staffMangaData: [Response.StaffDetailData.StaffData.Staff.StaffMedia.Edge] = []
    private var cancellables: Set<AnyCancellable> = []
    
    init(staffId: Int) {
        AnimeDataFetcher.shared.fetchStaffDetailByID(id: staffId)
            .sink { _ in
                
            } receiveValue: { staffData in
                AnimeDataFetcher.shared.isFetchingData = false
                self.staffData = staffData
                self.staffAnimeData = staffData.staffMedia.edges.compactMap({ staffMedia in
                    if staffMedia.node.type.uppercased() == "Anime".uppercased() {
                        return staffMedia
                    } else {
                        return nil
                    }
                })
                self.staffMangaData = staffData.staffMedia.edges.compactMap({ staffMedia in
                    if staffMedia.node.type.uppercased() == "Manga".uppercased() {
                        return staffMedia
                    } else {
                        return nil
                    }
                })
            }
            .store(in: &cancellables)

    }
}
