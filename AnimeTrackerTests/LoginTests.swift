//
//  LoginTests.swift
//  LoginTests
//
//  Created by YI-CHUN CHIU on 2025/6/4.
//

import XCTest
import Combine
@testable import AnimeTracker

final class LoginTests: XCTestCase {
    
    var viewModel: LoginViewViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = LoginViewViewModel(loginDataProvider: LoginMockData())
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
    }

    func testEmailFieldNil() {
        viewModel.userEmail.value = ""
        viewModel.userPassword.value = "somePassword"
        
        let exception = XCTestExpectation(description: "Email is Empty")
        viewModel.output.shouldNavigateToHomePage
            .sink { shouldNavigateToHomePage in
                if shouldNavigateToHomePage == false {
                    exception.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.input.didPressLogin.send(())
        
        wait(for: [exception], timeout: 5)
    }
    
    func testPasswordFieldNil() {
        viewModel.userEmail.value = "someEmail@gmail.com"
        viewModel.userPassword.value = ""
        
        let exception = XCTestExpectation(description: "Password is Empty")
        
        viewModel.output.shouldNavigateToHomePage
            .sink { shouldNavigateToHomePage in
                if shouldNavigateToHomePage == false {
                    exception.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.input.didPressLogin.send(())
        wait(for: [exception], timeout: 5)
    }
    
    func testLoginSuccess() {
        viewModel.userEmail.value = "someEmail@gmail.com"
        viewModel.userPassword.value = "123456"
        
        let exception = XCTestExpectation(description: "Login Success")
        
        viewModel.output.shouldNavigateToHomePage
            .sink { shouldNavigateToHomePage in
                if shouldNavigateToHomePage == true {
                    exception.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.input.didPressLogin.send(())
        wait(for: [exception], timeout: 5)
    }
}
