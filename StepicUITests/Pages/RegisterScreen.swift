import Foundation
import XCTest

class RegisterScreen: BaseScreen {
    private lazy var nameTextField = app.textFields[AccessibilityIdentifiers.Registration.nameTextField]
    private lazy var emailTextField = app.textFields[AccessibilityIdentifiers.Registration.emailTextField]
    private lazy var passwordTextField = app.secureTextFields[AccessibilityIdentifiers.Registration.passwordTextField]
    private lazy var registerButton = app.buttons[AccessibilityIdentifiers.Registration.registerButton]

    func fillUserInfo(name: String, email: String, password: String) {
        typeText(element: self.nameTextField, value: name)
        typeText(element: self.emailTextField, value: email)
        typeText(element: self.passwordTextField, value: password)
    }

    func clickRegister() {
        XCTAssertTrue(self.registerButton.waitForExistence(timeout: 10), "No 'Register' button")
        self.registerButton.tap()
    }
}
