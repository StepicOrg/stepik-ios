import Foundation
import XCTest

final class RegisterTests: BaseTest {
    let onbordingScreen = OnboardingScreen()
    let navigationTabs = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    let authScreen = AuthScreen()
    let registerScreen = RegisterScreen()

    override func setUp() {
        CommonActions.App.delete()
        super.setUp()

        self.addUIInterruptionMonitor(
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

        self.onbordingScreen.closeOnbording()

        self.app.tap()

        self.navigationTabs.openProfile()
        self.profileScreen.clickSingIn()

        self.authScreen.clickRegister()

        self.registerScreen.fillUserInfo(name: name, email: email, password: cts)
        self.registerScreen.clickRegister()

        self.profileScreen.shouldBeUserProfile(name: name)
    }
}
