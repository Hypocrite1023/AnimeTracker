//
//  Common+TextField.swift
//  AnimeTrackerUITests
//
//  Created by YI-CHUN CHIU on 2025/6/11.
//

import XCTest

extension XCUIElement {
    func deleteText() {
        guard let stringValue = self.value as? String, stringValue.count > 0 else { return }
        self.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}

extension XCUIApplication {
    func navigateToTrending() {
        let tabBar = tabBars.firstMatch.buttons["Trending"]
        tabBar.tap()
    }
    
    func navigateToLoginPage() {
        navigateToTrending()
        let userConfigurationButton = navigationBars.buttons.firstMatch
        userConfigurationButton.tap()
    }
}

