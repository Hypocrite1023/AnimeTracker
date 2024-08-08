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
    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.delegate = self
            usernameTextField.tag = 0
        }
    }
    
    @IBOutlet weak var userEmailTextField: UITextField! {
        didSet {
            userEmailTextField.delegate = self
            userEmailTextField.tag = 0
        }
    }
    @IBOutlet weak var userPasswordTextField: UITextField! {
        didSet {
            userPasswordTextField.delegate = self
            userPasswordTextField.tag = 0
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerUser(_ sender: Any) {
        guard let username = usernameTextField.text, usernameTextField.text != "" else {
            print("Username should not be null.")
            let alertController = UIAlertController(title: "Registration Error", message: "Username should not be null.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
            return
        }
        guard let userEmail = userEmailTextField.text, userEmailTextField.text != "" else {
            print("User email should not be null.")
            let alertController = UIAlertController(title: "Registration Error", message: "User email should not be null.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
            return
        }
        guard let userPassword = userPasswordTextField.text, userPasswordTextField.text != "" else {
            print("User password should not be null.")
            let alertController = UIAlertController(title: "Registration Error", message: "User password should not be null.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
            return
        }
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { authDataResult, error in
            if let error = error {
                let alertController = UIAlertController(title: "Registration Error", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(okAction)
                self.present(alertController, animated: true)
                return
            }
            
            if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                changeRequest.displayName = username
                changeRequest.commitChanges { (error) in
                    if let error = error {
                        print("change request failed \(error.localizedDescription)")
                        return
                    }
                }
            }
            
            self.view.endEditing(true)
            
            let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
            self.navigationController?.setViewControllers([mainPage], animated: true)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
