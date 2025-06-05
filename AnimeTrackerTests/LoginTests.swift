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
        viewModel.userEmail = ""
        viewModel.userPassword = "somePassword"
        
        let exception = XCTestExpectation(description: "Email is Empty")
        viewModel.login()
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Should not finish")
                case .failure(let error):
                    XCTAssertEqual(error as? LoginError, LoginError.emailFieldEmpty)
                    exception.fulfill()
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        wait(for: [exception], timeout: 5)
    }
    
    func testPasswordFieldNil() {
        viewModel.userEmail = "someEmail@gmail.com"
        viewModel.userPassword = ""
        
        let exception = XCTestExpectation(description: "Password is Empty")
        viewModel.login()
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("Should not finish")
                case .failure(let error):
                    XCTAssertEqual(error as? LoginError, LoginError.passwordFieldEmpty)
                    exception.fulfill()
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
        wait(for: [exception], timeout: 5)
    }
    
    func testLoginSuccess() {
        viewModel.userEmail = "someEmail@gmail.com"
        viewModel.userPassword = "123456"
        
        let expectation = XCTestExpectation(description: "Login Success")
        viewModel.shouldNavigateToHomePage
            .sink { should in
                XCTAssertTrue(should)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        viewModel.didPressLogin.send(())
        wait(for: [expectation], timeout: 5)
    }
}
