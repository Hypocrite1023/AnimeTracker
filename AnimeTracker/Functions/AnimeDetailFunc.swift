//
//  AnimeDetailFunc.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/24.
//

import Foundation
import UIKit

struct AnimeDetailFunc {
    static func timeLeft(from timestamp: Int64) -> String {
        let currentDate = Date()
        let futureDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: futureDate)
        
        guard let days = components.day,
              let hours = components.hour,
              let minutes = components.minute
            else {
            return "Invalid timestamp"
        }
        
        return "\(days)d \(hours)h \(minutes)m"
    }
    static func startDateString(year: Int, month: Int, day: Int) -> String {
        switch(month) {
        case 1:
            return "Jan \(day), \(year)"
        case 2:
            return "Feb \(day), \(year)"
        case 3:
            return "Mar \(day), \(year)"
        case 4:
            return "Apr \(day), \(year)"
        case 5:
            return "May \(day), \(year)"
        case 6:
            return "Jun \(day), \(year)"
        case 7:
            return "Jul \(day), \(year)"
        case 8:
            return "Aug \(day), \(year)"
        case 9:
            return "Sep \(day), \(year)"
        case 10:
            return "Oct \(day), \(year)"
        case 11:
            return "Nov \(day), \(year)"
        case 12:
            return "Dec \(day), \(year)"
        default:
            return ""
        }
    }
    static func getMainStudio(from studios: MediaResponse.MediaData.Media.Studios) -> String {
        let studioNames = studios.edges.filter({
            $0.isMain
        })
        return studioNames.first?.node.name ?? ""
    }
    static func getProducers(from studios: MediaResponse.MediaData.Media.Studios) -> String {
        let studioNames = studios.edges.map({
            $0.node.name
        })
        return studioNames.joined(separator: ",")
    }
    static func updateAnimeDescription(animeDescription: String) -> NSMutableAttributedString? {
        var finalAttributedString = NSMutableAttributedString()
        let animeDescriptionAddFontSize = "<p style=\"font-size: 20px;\"><br>\(animeDescription)</p>"
        guard let data = animeDescriptionAddFontSize.data(using: .utf8) else { return nil }
        do {
            // Create attributed string from HTML
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )

            // Create and apply additional paragraph style
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 3
            paragraphStyle.headIndent = 3
            paragraphStyle.tailIndent = -3
            paragraphStyle.paragraphSpacingBefore = 20

            // Combine HTML attributed string with additional paragraph style
            let fullAttributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle
            ]

            finalAttributedString = NSMutableAttributedString(attributedString: attributedString)
            finalAttributedString.addAttributes(fullAttributes, range: NSRange(location: 0, length: finalAttributedString.length))

        } catch {
            print("Error creating attributed string from HTML")
        }
        return finalAttributedString
    }
}