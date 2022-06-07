import Foundation
import XCTest

class RegisterTests: BaseTest {
    let onbordingScreen = OnboardingScreen()
    let navigation = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    let authScreen = AuthScreen()
    let registerScreen = RegisterScreen()

    override func setUp() {
        deleteApplication()
        super.setUp()

        addUIInterruptionMonitor(
            withDescription: "“\(AppName.name)” Would Like to Send You Notifications"
        ) { alert -> Bool in
            let alertButton = alert.buttons["Allow"]
            if alert.elementType == .alert && alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
    }

    func testUserCanRegister() throws {
        let cts = String(Int64(Date().timeIntervalSince1970))
        let name = "Bot_\(cts)"
        let email = "ios_autotest_\(cts)@stepik.org"

        onbordingScreen.closeOnbording()
        app.tap()
        navigation.openProfile()
        profileScreen.clickSingIn()
        authScreen.clickRegister()
        registerScreen.fillUserInfo(name: name, email: email, password: cts)
        registerScreen.clickRegister()
        profileScreen.shouldBeUserProfile(name: name)
    }
}
