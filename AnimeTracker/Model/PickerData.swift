//
//  PickerData.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/15.
//

import Foundation

struct PickerData {
    static let yearPickerOption: [Int] = Array(1990...(Calendar.current.dateComponents(in: .current, from: .now).year!+1)).reversed()
    static let seasonPickerOption: [String] = ["Spring", "Summer", "Fall", "Winter"]
}
