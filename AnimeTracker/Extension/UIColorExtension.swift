//
//  UIColorExtension.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/27.
//

import UIKit

extension UIColor {
    convenience init?(hex: String?) {
        if hex == nil {
            // 預設
            self.init(cgColor: #colorLiteral(red: 0.05142392963, green: 0.394322753, blue: 0.6507966518, alpha: 1))
            return
        }
        var hexFormatted = hex!.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove # if present
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        // Ensure the string is of valid length
        guard hexFormatted.count == 6 else {
            return nil
        }
        
        // Convert hex string to RGB values
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
