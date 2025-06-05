//
//  NSObject+Ext.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/6/4.
//

import UIKit

extension UIView {
    @discardableResult
    func forSelf(_ configure: (Self) -> Void) -> Self {
        configure(self)
        return self
    }
}
