import Foundation
import XCTest

final class RegisterScreen: BaseScreen {
    private lazy var nameTextField = self.app.textFields[AccessibilityIdentifiers.Registration.nameTextField]
    private lazy var emailTextField = self.app.textFields[AccessibilityIdentifiers.Registration.emailTextField]
    private lazy var registerButton = self.app.buttons[AccessibilityIdentifiers.Registration.registerButton]
    private lazy var passwordTextField
        = self.app.secureTextFields[AccessibilityIdentifiers.Registration.passwordTextField]

    func fillUserInfo(name: String, email: String, password: String) {
        self.typeText(element: self.nameTextField, value: name)
        self.typeText(element: self.emailTextField, value: email)
        self.typeText(element: self.passwordTextField, value: password)
    }

    func clickRegister() {
        XCTAssertTrue(self.registerButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Register' button")
        self.registerButton.tap()
    }
}
