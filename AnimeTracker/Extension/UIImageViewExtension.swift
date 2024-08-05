//
//  UIImageViewExtension.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/18.
//

import Foundation
import UIKit
extension UIImageView {
    func loadImage(from url: String?) {
        if url == nil {
            self.image = UIImage(systemName: "photo")
            return
        }
        guard let imageURL = URL(string: url!) else {
            print("image url error")
            return
        }
        DispatchQueue.global().async {
            let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                guard let data = data, error == nil,
                      let image = UIImage(data: data),
                      let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Failed to load image from URL: \(imageURL)")
                    return
                }

                
                
                // Set the image on the main thread
                DispatchQueue.main.async {
                    // Resize the image
//                    let targetSize = self.frame.size
//                    let resizedImage = self.resizeImage(image: image, targetSize: targetSize)
                    self.image = image
                }
            }
            task.resume()
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        // Calculate the new size while maintaining the aspect ratio
        let widthRatio = image.size.width / targetSize.width
        let heightRatio = image.size.height / targetSize.height
        let newSize: CGSize
        
        if widthRatio > heightRatio {
            // Adjust width to fit height
            newSize = CGSize(width: image.size.width / heightRatio, height: targetSize.height)
        } else {
            // Adjust height to fit width
            newSize = CGSize(width: targetSize.width, height: image.size.height / widthRatio)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
