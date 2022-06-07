import Foundation
import XCTest

open class BaseTest: XCTestCase {
    private var baseScreen = BaseScreen()

    lazy var app = baseScreen.app

    override open func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(ru)"]
        app.launchArguments += ["-AppleLocale", "ru_RU"]
        app.launch()
    }

    override open func tearDown() {
        super.tearDown()
        app.terminate()
    }
}
