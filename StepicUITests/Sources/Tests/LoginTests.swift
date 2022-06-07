import Foundation
import XCTest

final class LoginTests: BaseTest {
    let navigationTabs = MainNavigationTabs()
    let profileScreen = ProfileScreen()
    let authScreen = AuthScreen()
    let registerScreen = RegisterScreen()
    let logInScreen = LogInScreen()
    let googleAuthScreen = GoogleAuthScreen()

    override func setUp() {
        super.setUp()

        if CommonActions.User.isAuthorized() {
            CommonActions.User.logOut()
        }
    }

    func testUserCanLogInWithEmail() throws {
        let cts = String(Int64(Date().timeIntervalSince1970))
        let name = "Bot_\(cts)"
        let email = "ios_autotest_\(cts)@stepik.org"

        CommonActions.User.registerNewUser(name: name, email: email, password: cts)
        self.navigationTabs.openProfile()
        self.profileScreen.clickSingIn()

        self.authScreen.clickLoginWithEmail()

        self.logInScreen.fillUserInfo(email: email, password: cts)
        self.logInScreen.clickLogIn()

        self.profileScreen.shouldBeUserProfile(name: name)
    }

    //    func testUserCanLogInWithGoogle() throws {
    //        // decide where to store google account "stepik.qa4@gmail.com", "Qq0987654321Qq"
    //        self.addUIInterruptionMonitor(withDescription: "“Stepik” Wants to Use “google.com” to Sign In") { alert in
    //            let alertButton = alert.buttons["Continue"]
    //            if alertButton.exists {
    //                alertButton.tap()
    //                return true
    //            }
    //            return false
    //        }
    //        navigation.openProfile()
    //        profileScreen.clickSingIn()
    //        authScreen.clickLogInWithGoogle()
    //        googleAuthScreen.singIn(email: "", password: "")
    //        profileScreen.shouldBeUserProfile(name: "")
    //    }
}
