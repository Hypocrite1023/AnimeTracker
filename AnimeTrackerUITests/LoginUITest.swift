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
    
    func testEmailPasswordEmpty() throws {
        setLogoutSituation()
        clearEmailPasswordFields()
        tapLoginButton()
        expectToSeeAlert(with: "Login Error")
    }
    
    func testEmailEmpty() throws {
        setLogoutSituation()
        clearEmailPasswordFields()
        fillPasswordField(with: "password123")
        tapLoginButton()
        expectToSeeAlert(with: "Login Error")
    }
    
    func testPasswordEmpty() throws {
        setLogoutSituation()
        clearEmailPasswordFields()
        fillEmailField(with: "ui.test@example.com")
        tapLoginButton()
        expectToSeeAlert(with: "Login Error")
    }
    
    func testWrongEmail() throws {
        setLogoutSituation()
        clearEmailPasswordFields()
        fillEmailField(with: "ui.test@wrong.com")
        fillPasswordField(with: "password123")
        tapLoginButton()
        expectToSeeAlert(with: "Login Error")
    }
    
    func testWrongPassword() throws {
        setLogoutSituation()
        clearEmailPasswordFields()
        fillEmailField(with: "ui.test@example.com")
        fillPasswordField(with: "wrongpassword123")
        tapLoginButton()
        expectToSeeAlert(with: "Login Error")
    }
    
    func testNormalLogin() throws {
        setLogoutSituation()
        clearEmailPasswordFields()
        fillEmailField(with: "ui.test@example.com")
        fillPasswordField(with: "password123")
        tapLoginButton()
        expectNotToSeeAlert()
    }
}

// MARK: - LoginUITest func
extension LoginUITest {
    
    func setLogoutSituation() {
        app.launchArguments = ["UITEST_LOGOUT"]
        app.launch()
        
        app.navigateToTrending()
        app.navigateToLoginPage()
    }
    
    func clearEmailPasswordFields() {
        app.textFields["userEmailTextField"].deleteText()
        app.textFields["userEmailTextField"].deleteText()
    }
    
    func tapLoginButton() {
        app.buttons["loginBtn"].tap()
    }
    
    func fillEmailField(with email: String) {
        app.textFields["userEmailTextField"].tap()
        app.textFields["userEmailTextField"].typeText(email)
    }
    
    func fillPasswordField(with password: String) {
        app.secureTextFields["userPasswordTextField"].tap()
        app.secureTextFields["userPasswordTextField"].typeText(password)
    }
    
    func expectToSeeAlert(with title: String?, timeout: TimeInterval = 5) {
        if let title = title {
            let alert = app.alerts[title].waitForExistence(timeout: timeout)
            XCTAssertTrue(alert, "Alert not found")
        }
        let alert = app.alerts.firstMatch.waitForExistence(timeout: timeout)
        return XCTAssertTrue(alert, "Alert not found")
    }
    
    func expectNotToSeeAlert(timeout: TimeInterval = 5) {
        let alert = app.alerts.firstMatch
        XCTAssertFalse(alert.waitForExistence(timeout: timeout), "Alert should not found")
    }
}
