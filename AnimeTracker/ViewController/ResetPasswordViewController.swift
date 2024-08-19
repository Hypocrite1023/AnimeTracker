//
//  ResetPasswordViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/14.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        print("reset")
        guard let emailAddr = emailTextField.text, emailAddr != "" else {
            let alertController = UIAlertController(title: "Email address cannot be null.", message: "Please retype your email address.", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel) { action in
                self.dismiss(animated: true)
            }
            alertController.addAction(okayAction)
            self.present(alertController, animated: true)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: emailAddr) { error in
            if let error = error {
                let alertController = UIAlertController(title: "Some Error Occur.", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel) { action in
                    self.dismiss(animated: true)
                }
                alertController.addAction(okayAction)
                self.present(alertController, animated: true)
            } else {
                let alertController = UIAlertController(title: "We have sent you a reset password email, please check your mail box.", message: nil, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel) { action in
                    self.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true)
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
