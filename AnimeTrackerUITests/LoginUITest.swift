//
//  AnimeTrackerUITestsLaunchTests.swift
//  AnimeTrackerUITests
//
//  Created by YI-CHUN CHIU on 2025/6/4.
//

import XCTest

final class LoginUITest: XCTestCase {
    
    var app: XCUIApplication!

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    @MainActor
    func testLoginFlow() throws {
        app.launchArguments = ["UITEST_LOGOUT"]
        app.launch()
        
        let emailTextField = app.textFields["userEmailTextField"]
        let passwordTextField = app.secureTextFields["userPasswordTextField"]
        let loginButton = app.buttons["loginBtn"]
        
        XCTAssertTrue(emailTextField.exists)
        XCTAssertTrue(passwordTextField.exists)
        XCTAssertTrue(loginButton.exists)
        
        emailTextField.tap()
        emailTextField.typeText("ui.test@example.com")
        
        passwordTextField.tap()
        passwordTextField.typeText("password123")
        
        loginButton.tap()
        
        let trendingCollectionView = app.collectionViews["trendingCollectionView"]
        XCTAssertTrue(trendingCollectionView.waitForExistence(timeout: 5))
    }
    
    @MainActor
    func testResetPasswordFlow() throws {
        app.launchArguments = ["UITEST_LOGOUT"]
        app.launch()
        
        let resetPasswordButton = app.buttons["resetPasswordBtn"]
        resetPasswordButton.tap()
        
        let emailTextField = app.textFields["resetPasswordEmailTextField"]
    }
}
