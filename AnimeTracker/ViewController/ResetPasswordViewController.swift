//
//  ResetPasswordViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/14.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField! // user email address textfield
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
//    fileprivate func setupAlertController(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true)
//    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        print("reset")
        guard let emailAddr = emailTextField.text, emailAddr != "" else { // check email address field not null
            AlertWithMessageController.setupAlertController(title: "Email address cannot be null.", message: "Please type your email address.", viewController: self)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: emailAddr) { error in
            if let error = error {
                AlertWithMessageController.setupAlertController(title: "Reset Password Error", message: error.localizedDescription, viewController: self)
            } else {
//                AlertWithMessageController.setupAlertController(title: "If the email address is already registered, we will send a password reset email to your email address.", message: nil, viewController: self)
//                self.navigationController?.popViewController(animated: true) // pop to login page
                let alertController = UIAlertController(title: "If the email address is already registered, we will send a password reset email to your email address.", message: nil, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel) { action in
                    self.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true) // pop to login page
                }
                alertController.addAction(okayAction)
                self.present(alertController, animated: true)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
