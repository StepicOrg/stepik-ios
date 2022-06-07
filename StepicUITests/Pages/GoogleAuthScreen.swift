import Foundation
import XCTest

class GoogleAuthScreen: BaseScreen {
    private lazy var changeAccountText = app.webViews.webViews.webViews.staticTexts["Сменить аккаунт"]
    private lazy var emailTextField = app.webViews.webViews.webViews.textFields.element(boundBy: 0)
    private lazy var passwordTextField = app.webViews.webViews.webViews.secureTextFields.element(boundBy: 0)
    private lazy var nextButton = app.webViews.webViews.webViews.buttons["Далее"]


    func singIn(email: String, password: String) {
        if self.changeAccountText.waitForExistence(timeout: 1) {
            self.changeAccountText.tap()
        }
        app.tap()
        typeText(element: self.emailTextField, value: email)
        app.tap()
        self.nextButton.tap()
        typeText(element: self.passwordTextField, value: password)
        app.tap()
        self.nextButton.tap()
        // next step is to verify account, need to reseach how work with it
    }
}
