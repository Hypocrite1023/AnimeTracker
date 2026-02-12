//
//  DesignSystem.swift
//  AnimeTracker
//
//  Created by Gemini Agent.
//

import UIKit
import SwiftUI

// MARK: - Design System Config
struct DesignSystem {
    struct Palette {
        // Light Mode Colors
        static let primaryBlue = "#0D64A6"
        static let secondaryGold = "#FFC107"
        static let accentPink = "#FF4081"
        
        static let successGreen = "#28A745"
        static let warningOrange = "#FD7E14"
        static let errorRed = "#DC3545"
        static let infoBlue = "#17A2B8"

        // Backgrounds
        static let bgLight = "#FFFFFF"
        static let bgLightSecondary = "#F8F9FA"
        static let bgLightTertiary = "#E9ECEF"
        
        static let bgDark = "#121212"
        static let bgDarkSecondary = "#1E1E1E"
        static let bgDarkTertiary = "#2C2C2E"

        // Labels
        static let labelLight = "#212529"
        static let labelLightSecondary = "#6C757D"
        static let labelLightTertiary = "#ADB5BD"
        
        static let labelDark = "#F8F9FA"
        static let labelDarkSecondary = "#CED4DA"
        static let labelDarkTertiary = "#6C757D"
    }
}

// MARK: - UIColor Extension (UIKit)
extension UIColor {
    // 品牌核心色
    static let atPrimary = UIColor(hex: DesignSystem.Palette.primaryBlue)!
    static let atSecondary = UIColor(hex: DesignSystem.Palette.secondaryGold)!
    static let atAccent = UIColor(hex: DesignSystem.Palette.accentPink)!
    
    // 狀態色
    static let atSuccess = UIColor(hex: DesignSystem.Palette.successGreen)!
    static let atWarning = UIColor(hex: DesignSystem.Palette.warningOrange)!
    static let atError = UIColor(hex: DesignSystem.Palette.errorRed)!
    static let atInfo = UIColor(hex: DesignSystem.Palette.infoBlue)!

    // 動態背景色 (自動切換 Dark Mode)
    static let atBackground = createDynamicColor(light: DesignSystem.Palette.bgLight, dark: DesignSystem.Palette.bgDark)
    static let atSecondaryBackground = createDynamicColor(light: DesignSystem.Palette.bgLightSecondary, dark: DesignSystem.Palette.bgDarkSecondary)
    static let atTertiaryBackground = createDynamicColor(light: DesignSystem.Palette.bgLightTertiary, dark: DesignSystem.Palette.bgDarkTertiary)

    // 動態文字色
    static let atLabel = createDynamicColor(light: DesignSystem.Palette.labelLight, dark: DesignSystem.Palette.labelDark)
    static let atSecondaryLabel = createDynamicColor(light: DesignSystem.Palette.labelLightSecondary, dark: DesignSystem.Palette.labelDarkSecondary)
    static let atTertiaryLabel = createDynamicColor(light: DesignSystem.Palette.labelLightTertiary, dark: DesignSystem.Palette.labelDarkTertiary)
    
    // 分隔線
    static let atSeparator = createDynamicColor(light: "#DEE2E6", dark: "#38383A")

    private static func createDynamicColor(light: String, dark: String) -> UIColor {
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark)! : UIColor(hex: light)!
        }
    }
}

// MARK: - Color Extension (SwiftUI)
extension Color {
    static let atPrimary = Color(uiColor: .atPrimary)
    static let atSecondary = Color(uiColor: .atSecondary)
    static let atAccent = Color(uiColor: .atAccent)
    
    static let atSuccess = Color(uiColor: .atSuccess)
    static let atWarning = Color(uiColor: .atWarning)
    static let atError = Color(uiColor: .atError)
    static let atInfo = Color(uiColor: .atInfo)

    static let atBackground = Color(uiColor: .atBackground)
    static let atSecondaryBackground = Color(uiColor: .atSecondaryBackground)
    static let atTertiaryBackground = Color(uiColor: .atTertiaryBackground)

    static let atLabel = Color(uiColor: .atLabel)
    static let atSecondaryLabel = Color(uiColor: .atSecondaryLabel)
    static let atTertiaryLabel = Color(uiColor: .atTertiaryLabel)
    
    static let atSeparator = Color(uiColor: .atSeparator)
}

// MARK: - Typography (SwiftUI)
extension Font {
    /// 34pt, Bold, Rounded
    /// - 用途：頁面的最大標題 (Large Title)。
    /// - 特色：在頁面頂部提供強烈的視覺重心。
    static let atLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    
    /// 28pt, Bold, Rounded
    /// - 用途：主要區塊或頁面的一級標題 (Title 1)。
    /// - 特色：適合用於頁面切換後的核心標題。
    static let atTitle1 = Font.system(size: 28, weight: .bold, design: .rounded)
    
    /// 22pt, Semibold, Rounded
    /// - 用途：卡片標題、彈窗標題 (Title 2)。
    /// - 特色：兼具易讀性與強調感，是 App 中最常用的標題字級。
    static let atTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    
    /// 20pt, Semibold, Rounded
    /// - 用途：子章節標題、次要重點 (Title 3)。
    /// - 特色：用於區分同頁面內的不同功能區塊。
    static let atTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    /// 17pt, Semibold, Rounded
    /// - 用途：強調的內文、按鈕文字 (Headline)。
    /// - 特色：字級同內文但加粗，適合用於需要引人注意的資訊。
    static let atHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    /// 17pt, Regular, Rounded
    /// - 用途：標準內文 (Body)。
    /// - 特色：最適合閱讀長篇劇本介紹或評論。
    static let atBody = Font.system(size: 17, weight: .regular, design: .rounded)
    
    /// 15pt, Regular, Rounded
    /// - 用途：副標題、次要描述 (Subheadline)。
    /// - 特色：用於顯示如日期、作者、分類等輔助資訊。
    static let atSubheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    
    /// 13pt, Regular, Rounded
    /// - 用途：標籤文字、極小說明 (Caption)。
    /// - 特色：用於佔位符、法律聲明或不重要的註解。
    static let atCaption = Font.system(size: 13, weight: .regular, design: .rounded)
}

// MARK: - Typography (UIKit)
extension UIFont {
    /// 34pt, Bold, Rounded
    /// - 用途：頁面的最大標題 (Large Title)。
    static let atLargeTitle = UIFont.systemFont(ofSize: 34, weight: .bold).rounded()
    
    /// 28pt, Bold, Rounded
    /// - 用途：主要區塊或頁面的一級標題 (Title 1)。
    static let atTitle1 = UIFont.systemFont(ofSize: 28, weight: .bold).rounded()
    
    /// 22pt, Semibold, Rounded
    /// - 用途：卡片標題、彈窗標題 (Title 2)。
    static let atTitle2 = UIFont.systemFont(ofSize: 22, weight: .semibold).rounded()
    
    /// 20pt, Semibold, Rounded
    /// - 用途：子章節標題、次要重點 (Title 3)。
    static let atTitle3 = UIFont.systemFont(ofSize: 20, weight: .semibold).rounded()
    
    /// 17pt, Semibold, Rounded
    /// - 用途：強調的內文、按鈕文字 (Headline)。
    static let atHeadline = UIFont.systemFont(ofSize: 17, weight: .semibold).rounded()
    
    /// 17pt, Regular, Rounded
    /// - 用途：標準內文 (Body)。
    static let atBody = UIFont.systemFont(ofSize: 17, weight: .regular).rounded()
    
    /// 15pt, Regular, Rounded
    /// - 用途：副標題、次要描述 (Subheadline)。
    static let atSubheadline = UIFont.systemFont(ofSize: 15, weight: .regular).rounded()
    
    /// 13pt, Regular, Rounded
    /// - 用途：標籤文字、極小說明 (Caption)。
    static let atCaption = UIFont.systemFont(ofSize: 13, weight: .regular).rounded()

    private func rounded() -> UIFont {
        guard let descriptor = self.fontDescriptor.withDesign(.rounded) else { return self }
        return UIFont(descriptor: descriptor, size: self.pointSize)
    }
    
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        if let descriptor = self.fontDescriptor.withSymbolicTraits(traits) {
            return UIFont(descriptor: descriptor, size: 0) // size 0 means keep original size
        }
        return self
    }
}
