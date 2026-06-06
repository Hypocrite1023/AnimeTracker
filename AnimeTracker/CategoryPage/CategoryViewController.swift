//
//  CategoryViewController.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2024/12/28.
//

import UIKit
import SwiftUI

class CategoryViewController: UIViewController {

    private var lastDirection: CategoryView.ScrollDirection?

    override func viewDidLoad() {
        super.viewDidLoad()

        let swiftUIView = CategoryView(
            onAnimeTap: { animeID in
                let vc = AnimeDetailsViewController(animeID: animeID)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        )
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
