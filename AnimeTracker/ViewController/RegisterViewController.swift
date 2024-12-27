//
//  RegisterViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField! { // username
        didSet {
            usernameTextField.delegate = self
            usernameTextField.tag = 0
            usernameTextField.widthAnchor.constraint(equalToConstant: usernameTextField.frame.width).isActive = true
        }
    }
    
    @IBOutlet weak var userEmailTextField: UITextField! { // user email
        didSet {
            userEmailTextField.delegate = self
            userEmailTextField.tag = 1
        }
    }
    @IBOutlet weak var userPasswordTextField: UITextField! { // user password
        didSet {
            userPasswordTextField.delegate = self
            userPasswordTextField.tag = 2
        }
    }
    @IBOutlet weak var secondCheckUserPasswordTextField: UITextField! { // user password chack field
        didSet {
            secondCheckUserPasswordTextField.delegate = self
            secondCheckUserPasswordTextField.tag = 3
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // tap the non textfield place to close the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - 警告訊息
//    fileprivate func setupAlertController(title: String, message: String) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .cancel)
//        alertController.addAction(okAction)
//        self.present(alertController, animated: true)
//    }
    
    @IBAction func registerUser(_ sender: Any) {
        guard let username = usernameTextField.text, usernameTextField.text != "" else { // check username
            print("Username should not be null.")
            AlertWithMessageController.setupAlertController(title: "Registration Error", message: "User name should not be null.", viewController: self)
            return
        }
        guard let userEmail = userEmailTextField.text, userEmailTextField.text != "" else { // check user email
            print("User email should not be null.")
            AlertWithMessageController.setupAlertController(title: "Registration Error", message: "User email should not be null.", viewController: self)
            return
        }
        guard let userPassword = userPasswordTextField.text, userPasswordTextField.text != "" else { // check user password
            print("User password should not be null.")
            AlertWithMessageController.setupAlertController(title: "Registration Error", message: "User password should not be null.", viewController: self)
            return
        }
        guard let secondCheckPassword = secondCheckUserPasswordTextField.text, secondCheckUserPasswordTextField.text != "", userPassword == secondCheckPassword else { // check two password field should same and not null
            print("Password did not match.")
            AlertWithMessageController.setupAlertController(title: "Registration Error", message: "Two password should be same.", viewController: self)
            return
        }
        // use user provided user email and password to create account
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authDataResult, error in
            if let error = error {
                AlertWithMessageController.setupAlertController(title: "Registration Error", message: error.localizedDescription, viewController: self)
                return
            }
            
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() { // set the username to firebase
                changeRequest.displayName = username
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        print("change request failed \(error.localizedDescription)")
                        AlertWithMessageController.setupAlertController(title: "Setting username failed", message: error.localizedDescription, viewController: self)
                        return
                    }
                }
            }
            
            self.view.endEditing(true)
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                if let error = error {
                    AlertWithMessageController.setupAlertController(title: "Send Email Verification Error", message: error.localizedDescription, viewController: self)
                } else { // notify the user that we have sent verification email to them
//                    AlertWithMessageController.setupAlertController(title: "Email verification", message: "The verification mail have sent to your email, please check the mail and complete the sign up.", viewController: self)
                    
                    let emailVerificationAlertController = UIAlertController(title: "Email verification", message: "The verification mail have sent to your email, please check the mail and complete the sign up.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
                        self.dismiss(animated: true)
                        self.navigationController?.popViewController(animated: true) // pop to login page
                        return
                    }
                    emailVerificationAlertController.addAction(okAction)
                    self.present(emailVerificationAlertController, animated: true)
                }
            })
            
            
            
//            let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
//            self.navigationController?.setViewControllers([mainPage], animated: true)
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

extension RegisterViewController: UITextFieldDelegate {
    // when user tap keyboard enter, the cursor will move to the next textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
}
