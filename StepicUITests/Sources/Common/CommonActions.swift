import Foundation
import XCTest

enum CommonActions {
    enum App {
        static func delete() {
            let appName = AppName.name

            let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
            if springboard.icons[appName].waitForExistence(timeout: Constants.Timeout.small) {
                springboard.icons[appName].press(forDuration: 1.5)
            } else {
                return
            }

            springboard.collectionViews.buttons["Удалить приложение"].tap()
            springboard.alerts.scrollViews.otherElements.buttons["Удалить приложение"].tap()
            springboard.alerts.scrollViews.otherElements.buttons["Удалить"].tap()
        }
    }

    enum User {
        static func registerNewUser(name: String, email: String, password: String) {
            let navigationTabs = MainNavigationTabs()
            let profileScreen = ProfileScreen()
            let authScreen = AuthScreen()
            let registerScreen = RegisterScreen()

            navigationTabs.openProfile()
            profileScreen.clickSingIn()
            authScreen.clickRegister()
            registerScreen.fillUserInfo(name: name, email: email, password: password)
            registerScreen.clickRegister()

            self.logOut()
        }

        static func logOut() {
            let navigationTabs = MainNavigationTabs()
            let profileScreen = ProfileScreen()

            navigationTabs.openProfile()
            profileScreen.openSettings()
            profileScreen.logOut()
        }

        static func isAuthorized() -> Bool {
            let navigationTabs = MainNavigationTabs()
            let profileScreen = ProfileScreen()

            navigationTabs.openProfile()

            return profileScreen.isAuthorized()
        }
    }
}
