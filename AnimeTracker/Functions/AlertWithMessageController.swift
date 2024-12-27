//
//  AlertWithMessageController.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2024/12/27.
//

import Foundation
import UIKit

class AlertWithMessageController: UIAlertController {
    static func setupAlertController(title: String, message: String?, viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true)
    }
}
