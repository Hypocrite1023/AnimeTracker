//
//  LoginViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import Combine
import CombineExt
import Lottie
import SnapKit

class LoginViewController: UIViewController {
    //MARK: - email textField
    // the textfield that user input their email
    @IBOutlet weak var userEmailTextField: UITextField!
    //MARK: - password textField
    // the textfield that user input their password which the password relate to the email
    @IBOutlet weak var userPasswordTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgotPassBtn: UIButton!
    @IBOutlet weak var lottieAnimationContainer: UIView!
    
    private let viewModel: LoginViewViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        setupUI()
        setupPublisher()
        setupSubscriber()
    }
    
    private func setupUI() {
        userEmailTextField.keyboardType = .emailAddress
        userEmailTextField.returnKeyType = .next
        userEmailTextField.autocapitalizationType = .none
        userEmailTextField.autocorrectionType = .no
        userEmailTextField.accessibilityIdentifier = "userEmailTextField"
        
        userPasswordTextField.keyboardType = .default
        userPasswordTextField.returnKeyType = .done
        userPasswordTextField.autocapitalizationType = .none
        userPasswordTextField.autocorrectionType = .no
        userPasswordTextField.accessibilityIdentifier = "userPasswordTextField"
        
        loginBtn.accessibilityIdentifier = "loginBtn"
        
        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        
        let tapToCloseKeyboard = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard)) // tap the view to stop editing and close the keyboard
        self.view.addGestureRecognizer(tapToCloseKeyboard)
        
        // Load animation
        let animationView = LottieAnimationView(name: "Walking") // no .json
        // Configure
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        lottieAnimationContainer.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // Play
        animationView.play()
    }
    
    private func setupPublisher() {
        userEmailTextField.publisher(for: \.text)
            .removeDuplicates()
            .replaceNil(with: "")
            .assign(to: \.userEmail.value, on: viewModel)
            .store(in: &cancellables)
        
        userPasswordTextField.publisher(for: \.text)
            .removeDuplicates()
            .replaceNil(with: "")
            .assign(to: \.userPassword.value, on: viewModel)
            .store(in: &cancellables)
        
        loginBtn.tapPublisher
            .sink { [weak self] _ in
                self?.userEmailTextField.errorBorder(show: false)
                self?.userPasswordTextField.errorBorder(show: false)
                self?.view.endEditing(true)
                self?.viewModel.input.didPressLogin.send(())
            }
            .store(in: &cancellables)
        
        registerBtn.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
                self?.viewModel.input.didPressRegister.send(())
            }
            .store(in: &cancellables)
        
        forgotPassBtn.tapPublisher
            .sink { [weak self] _ in
                self?.view.endEditing(true)
                self?.viewModel.input.didPressForgotPassword.send(())
            }
            .store(in: &cancellables)
    }
    
    private func setupSubscriber() {
        viewModel.output.shouldNavigateToHomePage
            .filter{ $0 }
            .sink { [weak self] _ in
                let mainPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                self?.navigationController?.setViewControllers([mainPage], animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.shouldNavigateToRegister
            .sink { [weak self] _ in
                let registerPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController")
                self?.navigationController?.pushViewController(registerPage, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.shouldNavigateToForgotPassword
            .sink { [weak self] _ in
                let resetPasswordPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController")
                self?.navigationController?.pushViewController(resetPasswordPage, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.output.shouldShowError
            .sink { error in
                if let error = error as? LoginError {
                    switch error {
                    case .emailFieldEmpty:
                        self.userEmailTextField.errorBorder(show: true)
                    case .passwordFieldEmpty:
                        self.userPasswordTextField.errorBorder(show: true)
                    case .networkError:
                        break
                    }
                    AlertWithMessageController.setupAlertController(title: "Login Error", message: error.description, viewController: self)
                }
               
                AlertWithMessageController.setupAlertController(title: "Login Error", message: error.localizedDescription, viewController: self)
            }
            .store(in: &cancellables)
        
        viewModel.output.isLoggingProcessing
            .sink { [weak self] isProcessing in
                self?.loginBtn.isEnabled = !isProcessing
            }
            .store(in: &cancellables)
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.view.frame.origin.y = -keyboardFrame.height / 2
    }

    @objc private func keyboardWillHide(notification: Notification) {
        self.view.frame.origin.y = 0
    }
}

extension LoginViewController: UITextFieldDelegate {
    // when user tap keyboard enter, the cursor will move to the next textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userPasswordTextField {
            userEmailTextField.errorBorder(show: false)
            userPasswordTextField.errorBorder(show: false)
            viewModel.input.didPressLogin.send(())
            return true
        }
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    
}

extension UITextField {
    func errorBorder(show: Bool) {
        self.layer.borderColor = show ? UIColor.red.cgColor : UIColor.clear.cgColor
        self.layer.borderWidth = show ? 2 : 0
        self.layer.cornerRadius = 5
    }
}
