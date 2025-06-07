//
//  CategoryViewController.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2024/12/28.
//

import UIKit
import SwiftUI

class CategoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftUIView = CategoryView { animeID in
            let vc = UIStoryboard(name: "AnimeDetailPage", bundle: nil).instantiateViewController(identifier: "AnimeDetailView") as! AnimeDetailPageViewController
            vc.viewModel = AnimeDetailPageViewModel(animeID: animeID)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        hostingController.view.frame = self.view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
