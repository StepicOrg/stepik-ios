import XCTest

class LaunchArgumentsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func testOpenDeepLinkViaLaunchArgument() throws {
        // Given
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launchArguments += ["-AppleLocale", "en_EN"]
        app.launchArguments += ["-com.AlexKarpov.StepicUITests.DeepLink", "https://stepik.org/course/58852"]

        // When
        app.launch()

        // Then
        XCTAssertTrue(app.navigationBars.matching(identifier: "About course").element.waitForExistence(timeout: 5))
        app.terminate()
    }

    func testPassAuthorizeDataViaLaunchArgument() throws {
        // Given
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launchArguments += ["-AppleLocale", "en_EN"]
        app.launchArguments += ["-com.AlexKarpov.StepicUITests.SkipOnboarding"]
        app.launchArguments += ["-access_token", "{REPLACE_WITH_YOUR_ACCESS_TOKEN}"]
        app.launchArguments += ["-refresh_token", "{REPLACE_WITH_YOUR_REFRESH_TOKEN}"]
        app.launchArguments += ["-token_type", "Bearer"]
        app.launchArguments += ["-expire_date", "1649359149.782127"]
        app.launchArguments += ["-user_id", "21612976"]

        // When
        app.launch()

        // Then
        if app.tabBars["Tab Bar"].buttons["Profile"].waitForExistence(timeout: 5) {
            app.tabBars["Tab Bar"].buttons["Profile"].tap()
        }

        if app.buttons["User ID: 21612976"].waitForExistence(timeout: 5) {
            app.buttons["User ID: 21612976"].tap()
        } else {
            XCTFail("User not logged in")
        }

        app.terminate()
    }
}
