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
        
        guard let days = components.day, let hours = components.hour, let minutes = components.minute else {
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
    static func getMainStudio(from studios: Response.AnimeDetail.MediaData.Media.Studios?) -> String {
        guard let studios else { return "" }
        let studioNames = studios.edges.filter({
            $0.isMain
        })
        return studioNames.first?.node.name ?? ""
    }
    static func getProducers(from studios: Response.AnimeDetail.MediaData.Media.Studios?) -> String {
        guard let studios else { return "" }
        let studioNames = studios.edges.map({
            $0.node.name
        })
        return studioNames.joined(separator: ",")
    }
    static func updateAnimeDescription(animeDescription: String) -> NSMutableAttributedString? {
        // 1. Clean up <br> tags which might cause excessive spacing
        let cleanedDescription = animeDescription
            .replacingOccurrences(of: "<br><br>", with: "<br>")
            .replacingOccurrences(of: "\n", with: "") // Remove raw newlines, let HTML handle <br>
        
        guard let data = cleanedDescription.data(using: .utf8) else { return nil }
        
        do {
            // 2. Create attributed string from HTML
            // Note: This resets font to Times New Roman and color to black by default
            let attributedString = try NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
            
            let fullRange = NSRange(location: 0, length: attributedString.length)
            
            // 3. Define Base Font and Color from Design System
            let baseFont = UIFont.atBody
            let boldFont = UIFont.atHeadline // Semibold Rounded for Bold
            let italicFont = UIFont.atBody.withTraits(traits: .traitItalic) // Regular Rounded + Italic
            let baseColor = UIColor.atLabel
            
            // 4. Enumerate existing attributes to preserve traits (Bold/Italic) while changing Font Family
            attributedString.enumerateAttribute(.font, in: fullRange, options: []) { (value, range, stop) in
                if let currentFont = value as? UIFont {
                    let traits = currentFont.fontDescriptor.symbolicTraits
                    
                    var newFont = baseFont
                    
                    if traits.contains(.traitBold) {
                        newFont = boldFont
                    } else if traits.contains(.traitItalic) {
                        // Try to create Rounded Italic
                        if let roundedDescriptor = baseFont.fontDescriptor.withDesign(.rounded),
                           let italicDescriptor = roundedDescriptor.withSymbolicTraits(.traitItalic) {
                             newFont = UIFont(descriptor: italicDescriptor, size: baseFont.pointSize)
                        } else {
                            // Fallback to Standard System Italic if Rounded Italic is unavailable
                            newFont = UIFont.italicSystemFont(ofSize: baseFont.pointSize)
                        }
                    }
                    
                    attributedString.addAttribute(.font, value: newFont, range: range)
                }
            }
            
            // 5. Apply Global Color (Fix for Dark Mode)
            attributedString.addAttribute(.foregroundColor, value: baseColor, range: fullRange)
            
            // 6. Apply Paragraph Style
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.firstLineHeadIndent = 0 // Reset indent
            paragraphStyle.headIndent = 0
            paragraphStyle.paragraphSpacing = 12 // Spacing between paragraphs
            paragraphStyle.lineHeightMultiple = 1.2 // Better readability
            
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
            
            return attributedString
            
        } catch {
            print("Error creating attributed string from HTML: \(error)")
            return NSMutableAttributedString(string: animeDescription) // Fallback to raw string
        }
    }
    
    static func logScale(value: CGFloat, maxValue: CGFloat) -> CGFloat {
        return log(value + 1) / log(maxValue + 1)
    }
    
    static func partOfAmount(value: Int, totalValue: Int) -> CGFloat {
        return CGFloat(value) / CGFloat(totalValue)
    }
    
    static func mixColor(color1: UIColor, color2: UIColor, fraction: CGFloat) -> UIColor {
        var color1Red: CGFloat = 0
        var color1Green: CGFloat = 0
        var color1Blue: CGFloat = 0
        var color1Alpha: CGFloat = 0
        color1.getRed(&color1Red, green: &color1Green, blue: &color1Blue, alpha: &color1Alpha)
        
        var color2Red: CGFloat = 0
        var color2Green: CGFloat = 0
        var color2Blue: CGFloat = 0
        var color2Alpha: CGFloat = 0
        color2.getRed(&color2Red, green: &color2Green, blue: &color2Blue, alpha: &color2Alpha)
        
        let returnRed = color1Red * (1 - (fraction)) + (fraction) * color2Red
        let returnBlue = color1Blue * (1 - (fraction)) + (fraction) * color2Blue
        let returnGreen = color1Green * (1 - (fraction)) + (fraction) * color2Green
        let returnAlpha = color1Alpha * (1 - (fraction)) + (fraction) * color2Alpha
//        print(returnRed, returnGreen, returnBlue, returnAlpha)
        
        return UIColor(red: returnRed, green: returnGreen, blue: returnBlue, alpha: returnAlpha)
    }
    
    static func timePassed(from timestamp: Int64) -> String {
        let currentDate = Date()
        let pastDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: pastDate, to: currentDate)
        
        guard let days = components.day, let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return "Invalid timestamp"
        }
        
        if days >= 7 {
            return "\(days / 7) \(days / 7 > 1 ? "weeks ago" : "week ago")"
        } else {
            if days > 0 {
                return "\(days) \(days > 1 ? "days ago" : "day ago")"
            } else {
                if hours > 0 {
                    return "\(hours) \(hours > 1 ? "hours ago" : "hour ago")"
                } else {
                    if minutes > 0 {
                        return "\(minutes) \(minutes > 1 ? "minutes ago" : "minute ago")"
                    } else {
                        return "\(seconds) \(seconds > 1 ? "seconds ago" : "second ago")"
                    }
                }
            }
        }
    }
    static func airingTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSinceNow: timestamp)
        print(date)
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: Date.now, to: date)
        
        guard let days = components.day, let hours = components.hour, let minutes = components.minute else {
            return "Invalid timestamp"
        }
        
        return "Will Airing after: \(days)d \(hours)h \(minutes)m"
    }
    
    static func extractLinks(from text: String) -> [(text: String, link: String)] {
        var results: [(text: String, link: String)] = []
        
        // Regular expression pattern to match [text](link)
        let pattern = #"\[(.*?)\]\((.*?)\)"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            
            for match in matches {
                if let textRange = Range(match.range(at: 1), in: text),
                   let linkRange = Range(match.range(at: 2), in: text) {
                    let extractedText = String(text[textRange])
                    let extractedLink = String(text[linkRange])
                    results.append((text: extractedText, link: extractedLink))
                }
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        return results
    }
}
