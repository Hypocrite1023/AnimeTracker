//
//  LoginViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    //MARK: - email textField
    // the textfield that user input their email
    @IBOutlet weak var userEmailTextField: UITextField!
    //MARK: - password textField
    // the textfield that user input their password which the password relate to the email
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    private let viewModel: LoginViewViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        let tapToCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)) // tap the view to stop editing and close the keyboard
        self.view.addGestureRecognizer(tapToCloseKeyboard)
        
        userEmailTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.userEmail, on: viewModel)
            .store(in: &cancellables)
        
        userPasswordTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.userPassword, on: viewModel)
            .store(in: &cancellables)
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func login(_ sender: Any) {
        self.view.endEditing(true)
        viewModel.login()
            .receive(on: DispatchQueue.main)
            .timeout(.seconds(10), scheduler: RunLoop.main)
            .sink { completion in
                switch completion {
                    
                case .finished:
                    print("login success")
                    let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                    self.navigationController?.setViewControllers([mainPage], animated: true)
                case .failure(let error):
                    if let loginError = error as? LoginError {
                        print(loginError.description)
                        AlertWithMessageController.setupAlertController(title: "Login Error", message: loginError.description, viewController: self)
                    } else {
                        print(error.localizedDescription)
                        AlertWithMessageController.setupAlertController(title: "Login Error", message: error.localizedDescription, viewController: self)
                    }
                    
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
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
