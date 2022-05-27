//
//  General.swift
//  StepicUITests
//
//  Created by admin on 25.05.2022.
//  Copyright © 2022 Alex Karpov. All rights reserved.
//

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
    registerScreen
        .fillUserInfo(name: name, email: email, password: password)
        .clickRegister()
    logOut()
}

func logOut() {
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    navigation.openProfile()
    profileScreen
        .openSettings()
        .logOut()
}

func isUserAuthorized() -> Bool {
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    navigation.openProfile()
    if profileScreen.btnSingIn.waitForExistence(timeout: 5) {
        return false
    }
    return true
}
