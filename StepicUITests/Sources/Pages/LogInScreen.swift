import Foundation
import XCTest

final class LogInScreen: BaseScreen {
    private lazy var emailTextField = self.app.textFields[AccessibilityIdentifiers.AuthEmail.emailTextField]
    private lazy var passwordTextField = self.app.secureTextFields[AccessibilityIdentifiers.AuthEmail.passwordTextField]
    private lazy var logInButton = self.app.buttons[AccessibilityIdentifiers.AuthEmail.logInButton]

    func fillUserInfo(email: String, password: String) {
        self.typeText(element: self.emailTextField, value: email)
        self.typeText(element: self.passwordTextField, value: password)
    }

    func clickLogIn() {
        XCTAssertTrue(self.logInButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Log in' button")
        self.logInButton.tap()
    }
}
