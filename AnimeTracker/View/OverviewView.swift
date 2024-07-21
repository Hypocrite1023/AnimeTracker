//
//  OverviewView.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/21.
//

import UIKit

class OverviewView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var animeDescriptionDelegate: AnimeDescriptionDelegate?
    private var contentScrollView: UIScrollView!
    private var animeDescriptionLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
//        self.backgroundColor = .yellow
        contentScrollView = UIScrollView()
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentScrollView)
        animeDescriptionLabel = UILabel()
        animeDescriptionLabel.numberOfLines = 0
        animeDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentScrollView.addSubview(animeDescriptionLabel)
        
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: self.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//            tmpLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//            tmpLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//            tmpLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            animeDescriptionLabel.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
            animeDescriptionLabel.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
            animeDescriptionLabel.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
            animeDescriptionLabel.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
            animeDescriptionLabel.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("overviewview deinit")
    }
    
    func updateAnimeDescription() {
        guard let animeDescription = animeDescriptionDelegate?.passDescriptionAndUpdate() else {
            return
        }
        
        let animeDescriptionAddFontSize = "<p style=\"font-size: 20px;\">\(animeDescription)</p>"
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.firstLineHeadIndent = 10
//        paragraphStyle.headIndent = 10
//        paragraphStyle.tailIndent = -3
//        animeDescriptionLabel.attributedText = NSAttributedString(string: animeDescription, attributes: [.paragraphStyle: paragraphStyle])
        guard let data = animeDescriptionAddFontSize.data(using: .utf8) else { return }
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
            paragraphStyle.paragraphSpacingBefore = 5

            // Combine HTML attributed string with additional paragraph style
            let fullAttributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle
            ]

            let finalAttributedString = NSMutableAttributedString(attributedString: attributedString)
            finalAttributedString.addAttributes(fullAttributes, range: NSRange(location: 0, length: finalAttributedString.length))

            animeDescriptionLabel.attributedText = finalAttributedString
        } catch {
            print("Error creating attributed string from HTML")
        }
    }

}
