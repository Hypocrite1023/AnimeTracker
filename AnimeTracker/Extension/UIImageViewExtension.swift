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
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    print("HTTPURLResponse code \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                    return
                }
                if let error = error {
                    print(error.localizedDescription.debugDescription)
                }
                if let data = data {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        }
    }
}
