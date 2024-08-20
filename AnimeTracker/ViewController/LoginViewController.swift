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
    @IBOutlet weak var userEmailTextField: UITextField! { // the textfield that user input their email
        didSet {
//            userEmailTextField.becomeFirstResponder()
            userEmailTextField.tag = 0
            userEmailTextField.delegate = self
        }
    }
    @IBOutlet weak var userPasswordTextField: UITextField! { // the textfield that user input their password which the password relate to the email
        didSet {
            userPasswordTextField.tag = 1
            userPasswordTextField.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tapToCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)) // tap the view to stop editing and close the keyboard
        self.view.addGestureRecognizer(tapToCloseKeyboard)
    }
    
    @objc func closeKeyboard() {
//        self.userEmailTextField.resignFirstResponder()
//        self.userPasswordTextField.resignFirstResponder()
        self.view.endEditing(true)
    }
    fileprivate func setupErrorAlertController(title: String, message: String) {
        let errorAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        errorAlertController.addAction(okAction)
        
        self.present(errorAlertController, animated: true)
    }
    
    @IBAction func login(_ sender: Any) {
        guard let userEmail = userEmailTextField.text, userEmailTextField.text != "" else {
            setupErrorAlertController(title: "Login Error", message: "User email should not be null")
            return
        }
        guard let userPassword = userPasswordTextField.text, userPasswordTextField.text != "" else {
            setupErrorAlertController(title: "Login Error", message: "User password should not be null")
            return
        }
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (authResult, error) in // use user provide email and password to login
            if let error = error {
                self.setupErrorAlertController(title: "Some Error Occur", message: error.localizedDescription)
                return
            }
            
            self.view.endEditing(true) // stop the textfield in the view editing
            if let verified = Auth.auth().currentUser?.isEmailVerified {
                if verified { // if user complete email verify, they can go to the main page
                    let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        //            self.navigationController?.pushViewController(mainPage, animated: true)
                    self.navigationController?.setViewControllers([mainPage], animated: true)
                    AnimeNotification.shared.checkNotification()
                } else { // if not, that they need to complete the email verify
                    self.setupErrorAlertController(title: "You haven't completed the email verification yet.", message: "Go to your mail box and click the verifiction link.")
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
    // when user tap keyboard enter, the cursor will move to the next textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
