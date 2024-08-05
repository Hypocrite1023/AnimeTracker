//
//  OpenURLDelegate.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/5.
//

import Foundation

protocol OpenUrlDelegate: AnyObject {
    func openURL(siteName: String?, siteURL: String?)
}
