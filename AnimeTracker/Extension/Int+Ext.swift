//
//  Int+Ext.swift
//  AnimeTracker
//
//  Created by Rex Chiu on 2026/1/19.
//

import Foundation

extension Int {
    func makeTimeString() -> String {
        let day = self / 86400
        let hour = (self % 86400) / 3600
        let min = (self % 3600) / 60
        let sec = self % 60
        
        var str = ""
        if day > 0 {
            str += "\(day)D"
        }
        if hour > 0 {
            str += "\(hour)H"
        }
        if min > 0 {
            str += "\(min)M"
        }
        if str.count == 0 && sec > 0 {
            str += "\(sec)S"
        }
        
        if str.count == 0 {
            return "0 second"
        }
        
        return str
    }
}
