import Foundation
import XCTest

class OnboardingTests: BaseTest {
    let onbordingScreen = OnboardingScreen()
    let navigation = MainNavigationTabs()
    let authScreen = AuthScreen()
    let profileScreen = ProfileScreen()

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

    func testUserCanFollowOnboarding() throws {
        onbordingScreen.next()
        onbordingScreen.next()
        onbordingScreen.next()
        onbordingScreen.next()
        app.tap()
        authScreen.shouldBeAuthScreen()
    }

    func testUserCanCloseOnboarding() throws {
        onbordingScreen.closeOnbording()
        app.tap()
        navigation.openProfile()
        profileScreen.shouldBeSingInButton()
    }
}
