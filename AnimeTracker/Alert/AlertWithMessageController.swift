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
    
    static func setupTwoChoiceAlertController(title: String, message: String?, viewController: UIViewController, choice1: String, choice2: String, style1: UIAlertAction.Style = .cancel, style2: UIAlertAction.Style = .default, action1: ((UIAlertAction) -> Void)? = nil, action2: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction1 = UIAlertAction(title: choice1, style: style1, handler: action1)
        alertController.addAction(alertAction1)
        let alertAction2 = UIAlertAction(title: choice2, style: style2, handler: action2)
        alertController.addAction(alertAction2)
        viewController.present(alertController, animated: true)
    }
}

enum AlertType {
    case needLogin
    case apiError(message: String)
    
    var title: String {
        switch self {
        case .needLogin:
            return "Login Required"
        case .apiError:
            return "Api Error"
        }
    }
    
    var message: String? {
        switch self {
        case .needLogin:
            return "Please login to continue."
        case .apiError(let message):
            return "Reason: \(message)"
        }
    }
}
