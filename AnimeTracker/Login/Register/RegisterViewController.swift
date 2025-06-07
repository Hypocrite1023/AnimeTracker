//
//  RegisterViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/8.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import Combine
import Lottie

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var secondCheckUserPasswordTextField: UITextField!
    @IBOutlet weak var registerAnimationImageContainer: UIView!
    
    private let viewModel: RegisterViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.username, on: viewModel)
            .store(in: &cancellables)
        
        userEmailTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.userEmail, on: viewModel)
            .store(in: &cancellables)
        
        userPasswordTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.userPassword, on: viewModel)
            .store(in: &cancellables)
        
        secondCheckUserPasswordTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.confirmPassword, on: viewModel)
            .store(in: &cancellables)
        
        usernameTextField.delegate = self
        userEmailTextField.delegate = self
        userPasswordTextField.delegate = self
        secondCheckUserPasswordTextField.delegate = self
        
        // tap the non textfield place to close the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Load animation
        let animationView = LottieAnimationView(name: "register") // no .json
        // Configure
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        registerAnimationImageContainer.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // Play
        animationView.play()
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func registerUser(_ sender: Any) {
        self.view.endEditing(true)
        viewModel.register()
            .receive(on: DispatchQueue.main)
            .timeout(10, scheduler: RunLoop.main)
            .sink { completion in
                switch completion {
                    
                case .finished:
                    // notify the user that we have sent verification email to them
                    let emailVerificationAlertController = UIAlertController(title: "Email verification", message: "The verification mail have sent to your email, please check the mail and complete the sign up.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
                        self.dismiss(animated: true)
                        self.navigationController?.popViewController(animated: true) // pop to login page
                        return
                    }
                    emailVerificationAlertController.addAction(okAction)
                    self.present(emailVerificationAlertController, animated: true)
                case .failure(let error):
                    if let registerError = error as? RegisterError {
                        AlertWithMessageController.setupAlertController(title: "Registration Error", message: registerError.description, viewController: self)
                    } else {
                        AlertWithMessageController.setupAlertController(title: "Registration Error", message: error.localizedDescription, viewController: self)
                    }
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
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
