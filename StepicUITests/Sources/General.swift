import Foundation
import XCTest


func deleteApplication() {
    let appName = AppName.name

    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    if springboard.icons[appName].waitForExistence(timeout: 5) {
        springboard.icons[appName].press(forDuration: 1.5)
    } else {
        return
    }

    springboard.collectionViews.buttons["Удалить приложение"].tap()
    springboard.alerts.scrollViews.otherElements.buttons["Удалить приложение"].tap()
    springboard.alerts.scrollViews.otherElements.buttons["Удалить"].tap()
}

func registerNewUser(name: String, email: String, password: String) {
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    let authScreen = AuthScreen()
    let registerScreen = RegisterScreen()
    navigation.openProfile()
    profileScreen.clickSingIn()
    authScreen.clickRegister()
    registerScreen.fillUserInfo(name: name, email: email, password: password)
    registerScreen.clickRegister()
    logOut()
}

func logOut() {
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    navigation.openProfile()
    profileScreen.openSettings()
    profileScreen.logOut()
}

func isUserAuthorized() -> Bool {
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    navigation.openProfile()
    return profileScreen.isAuthorized()
}
