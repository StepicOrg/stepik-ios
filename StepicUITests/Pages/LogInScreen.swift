import Foundation
import XCTest

class LogInScreen: BaseScreen {
    private lazy var emailTextField = app.textFields[AccessibilityIdentifiers.AuthEmail.emailTextField]
    private lazy var passwordTextField = app.secureTextFields[AccessibilityIdentifiers.AuthEmail.passwordTextField]
    private lazy var logInButton = app.buttons[AccessibilityIdentifiers.AuthEmail.logInButton]

    func fillUserInfo(email: String, password: String) {
        typeText(element: self.emailTextField, value: email)
        typeText(element: self.passwordTextField, value: password)
    }

    func clickLogIn() {
        XCTAssertTrue(self.logInButton.waitForExistence(timeout: 10), "No 'Log in' button")
        self.logInButton.tap()
    }
}
