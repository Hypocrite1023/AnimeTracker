//
//  ResetPasswordViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/14.
//

import UIKit
import FirebaseAuth
import Combine
import Lottie

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField! // user email address textfield
    @IBOutlet weak var resetPasswordAnimationImageContainer: UIView!
    
    private let viewModel: ResetPasswordViewModel = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.publisher(for: \.text)
            .removeDuplicates()
            .assign(to: \.emailAddress, on: viewModel)
            .store(in: &cancellables)
        
        let closeKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(closeKeyboardGesture)
        
        emailTextField.delegate = self
        
        // tap the non textfield place to close the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // Load animation
        let animationView = LottieAnimationView(name: "forgetpass") // no .json
        // Configure
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        resetPasswordAnimationImageContainer.addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // Play
        animationView.play()
    }
    
    @objc func closeKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func resetPassword(_ sender: UIButton) {
        print("reset")
        view.endEditing(true)
        
        resetPassword()
    }
    
    func resetPassword() {
        viewModel.resetPassword()
            .receive(on: DispatchQueue.main)
            .timeout(5, scheduler: RunLoop.main)
            .sink { completion in
                switch completion {
                    
                case .finished:
                    let alertController = UIAlertController(title: "If the email address is already registered, we will send a password reset email to your email address.", message: nil, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel) { action in
                        self.dismiss(animated: true)
                        self.navigationController?.popViewController(animated: true) // pop to login page
                    }
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true)
                case .failure(let error):
                    if let resetPasswordError = error as? ResetPasswordError {
                        AlertWithMessageController.setupAlertController(title: "Reset Password Error", message: resetPasswordError.description, viewController: self)
                    } else {
                        AlertWithMessageController.setupAlertController(title: "Reset Password Error", message: error.localizedDescription, viewController: self)
                    }
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if textField == emailTextField {
            resetPassword()
            return true
        } else {
            return false
        }
    }
}
