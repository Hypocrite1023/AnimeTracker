//
//  UIView+Ext.swift
//  AnimeTracker
//
//  Created by Gemini Agent on 2026/02/21.
//

import UIKit

extension UIView {
    
    /// Rounds the specified corners of the view's layer.
    ///
    /// - Parameters:
    ///   - corners: A bitmask specifying the corners to round.
    ///   - radius: The radius of the rounded corners.
    func roundCorners(corners: CACornerMask, radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
        self.clipsToBounds = true
    }
}
