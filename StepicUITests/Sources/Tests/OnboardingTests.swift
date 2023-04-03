import Foundation
import XCTest

final class OnboardingTests: BaseTest {
    let onbordingScreen = OnboardingScreen()
    let navigationTabs = MainNavigationTabs()
    let authScreen = AuthScreen()
    let profileScreen = ProfileScreen()

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

    func testUserCanFollowOnboarding() throws {
        self.onbordingScreen.next()
        self.onbordingScreen.next()
        self.onbordingScreen.next()
        self.onbordingScreen.next()

        self.app.tap()

        self.authScreen.shouldBeAuthScreen()
    }

    func testUserCanCloseOnboarding() throws {
        self.onbordingScreen.closeOnbording()

        self.app.tap()

        self.navigationTabs.openProfile()
        self.profileScreen.shouldBeSingInButton()
    }
}
