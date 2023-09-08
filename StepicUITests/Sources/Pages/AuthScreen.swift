import Foundation
import XCTest

final class AuthScreen: BaseScreen {
    private lazy var loginWithEmailButton = self.app.buttons[AccessibilityIdentifiers.AuthSocial.signInButton]
    private lazy var registerButton = self.app.buttons[AccessibilityIdentifiers.AuthSocial.signUpButton]
    private lazy var googleButton = self.app.collectionViews.children(matching: .cell).element(boundBy: 2)

    func shouldBeAuthScreen() {
        XCTAssertTrue(
            self.loginWithEmailButton.waitForExistence(timeout: Self.defaultTimeout),
            "No 'Log in with email' button"
        )
        XCTAssertTrue(self.registerButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Register' button")
    }

    func clickRegister() {
        XCTAssertTrue(self.registerButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Register' button")
        self.registerButton.tap()
    }

    func clickLoginWithEmail() {
        XCTAssertTrue(
            self.loginWithEmailButton.waitForExistence(timeout: Self.defaultTimeout),
            "No 'Log in with email' button"
        )
        self.loginWithEmailButton.tap()
    }

    func clickLogInWithGoogle() {
        XCTAssertTrue(self.googleButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Google' button")
        self.googleButton.tap()
    }
}
