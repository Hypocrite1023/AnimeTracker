//
//  FloatingButtonManager.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import Foundation
import UIKit

class FloatingButtonManager {
    static let shared = FloatingButtonManager()
    
    var floatingButton: UIView!
    var floatingButtonMenu: FloatingButtonMenu!
    
    func addToView(toView view: UIView) {
        view.addSubview(floatingButton)
        floatingButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30).isActive = true
        floatingButton.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        floatingButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        let floatingButtonTapGesture = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        floatingButton.addGestureRecognizer(floatingButtonTapGesture)
        
        view.addSubview(floatingButtonMenu)
        floatingButtonMenu.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20).isActive = true
        floatingButtonMenu.topAnchor.constraint(equalTo: floatingButton.topAnchor, constant: -20).isActive = true
        floatingButtonMenu.heightAnchor.constraint(equalToConstant: 50).isActive = true
        floatingButtonMenu.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    private init() {
        floatingButton = UIView()
        let floatingButtonImage = UIImageView()
        floatingButtonImage.translatesAutoresizingMaskIntoConstraints = false
        floatingButtonImage.image = UIImage(systemName: "line.3.horizontal.circle.fill")
        floatingButtonImage.contentMode = .scaleAspectFit
        floatingButtonImage.backgroundColor = .white
        floatingButtonImage.layer.cornerRadius = 30
        floatingButtonImage.clipsToBounds = true
        floatingButton.addSubview(floatingButtonImage)
        floatingButtonImage.topAnchor.constraint(equalTo: floatingButton.topAnchor).isActive = true
        floatingButtonImage.leadingAnchor.constraint(equalTo: floatingButton.leadingAnchor).isActive = true
        floatingButtonImage.trailingAnchor.constraint(equalTo: floatingButton.trailingAnchor).isActive = true
        floatingButtonImage.bottomAnchor.constraint(equalTo: floatingButton.bottomAnchor).isActive = true
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        floatingButtonMenu = FloatingButtonMenu()
        floatingButtonMenu.translatesAutoresizingMaskIntoConstraints = false
    }
    @objc func showMenu(sender: UITapGestureRecognizer) {
        FloatingButtonMenu.isShow.toggle()
        UIView.animate(withDuration: 0.3) {
            self.floatingButtonMenu.transform = CGAffineTransform(translationX: (FloatingButtonMenu.isShow ? -(self.floatingButtonMenu.frame.minX - self.floatingButton.frame.minX + 20 + self.floatingButtonMenu.frame.width) : 0), y: 0)
        }
    }
    
    func bringFloatingButtonToFront(in view: UIView) {
        view.bringSubviewToFront(floatingButton)
    }
}

