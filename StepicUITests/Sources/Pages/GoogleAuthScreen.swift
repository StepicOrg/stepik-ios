import Foundation
import XCTest

final class GoogleAuthScreen: BaseScreen {
    private lazy var changeAccountText = self.app.webViews.webViews.webViews.staticTexts["Сменить аккаунт"]
    private lazy var emailTextField = self.app.webViews.webViews.webViews.textFields.element(boundBy: 0)
    private lazy var passwordTextField = self.app.webViews.webViews.webViews.secureTextFields.element(boundBy: 0)
    private lazy var nextButton = self.app.webViews.webViews.webViews.buttons["Далее"]

    func singIn(email: String, password: String) {
        if self.changeAccountText.waitForExistence(timeout: 1) {
            self.changeAccountText.tap()
        }

        self.app.tap()
        self.typeText(element: self.emailTextField, value: email)

        self.app.tap()
        self.nextButton.tap()
        self.typeText(element: self.passwordTextField, value: password)

        self.app.tap()
        self.nextButton.tap()
        // next step is to verify account, need to reseach how work with it
    }
}
