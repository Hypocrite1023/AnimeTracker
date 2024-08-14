//
//  LoginViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import FirebaseAuth
import FirebaseCore

class LoginViewController: UIViewController {
    @IBOutlet weak var userEmailTextField: UITextField! {
        didSet {
//            userEmailTextField.becomeFirstResponder()
            userEmailTextField.tag = 0
            userEmailTextField.delegate = self
        }
    }
    @IBOutlet weak var userPasswordTextField: UITextField! {
        didSet {
            userPasswordTextField.tag = 1
            userPasswordTextField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func login(_ sender: Any) {
        guard let userEmail = userEmailTextField.text, userEmailTextField.text != "" else {
            let errorAlertController = UIAlertController(title: "Login Error", message: "User email should not be null", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            errorAlertController.addAction(okAction)
            
            self.present(errorAlertController, animated: true)
            return
        }
        guard let userPassword = userPasswordTextField.text, userPasswordTextField.text != "" else {
            let errorAlertController = UIAlertController(title: "Login Error", message: "User password should not be null", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            errorAlertController.addAction(okAction)
            
            self.present(errorAlertController, animated: true)
            return
        }
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (authResult, error) in
            if let error = error {
                let errorAlertController = UIAlertController(title: "Some Error Occur", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                errorAlertController.addAction(okAction)
                
                self.present(errorAlertController, animated: true)
                return
            }
            
            self.view.endEditing(true)
            if let verified = Auth.auth().currentUser?.isEmailVerified {
                if verified {
                    let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        //            self.navigationController?.pushViewController(mainPage, animated: true)
                    self.navigationController?.setViewControllers([mainPage], animated: true)
                    AnimeNotification.shared.checkNotification()
                } else {
                    let errorAlertController = UIAlertController(title: "You haven't completed the email verification yet.", message: "Go to your mail box and click the verifiction link.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
                        self.dismiss(animated: true)
                    }
                    errorAlertController.addAction(okAction)
                    
                    self.present(errorAlertController, animated: true)
                }
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
