import Foundation
import XCTest

class BaseTest: XCTestCase {
    private lazy var baseScreen = BaseScreen()

    private(set) lazy var app = self.baseScreen.app

    override func setUp() {
        super.setUp()

        self.continueAfterFailure = false

        self.app.launchArguments += ["-AppleLanguages", "(ru)"]
        self.app.launchArguments += ["-AppleLocale", "ru_RU"]

        self.app.launch()
    }

    override func tearDown() {
        super.tearDown()
        self.app.terminate()
    }
}
