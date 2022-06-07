import Foundation
import XCTest

class BaseScreen {
    static let defaultTimeout: TimeInterval = Constants.Timeout.default
    static let smallTimeout: TimeInterval = Constants.Timeout.small

    private(set) var app = XCUIApplication()

    func typeText(element: XCUIElement, value: String) {
        XCTAssertTrue(element.waitForExistence(timeout: Self.defaultTimeout), "No field \(element)")
        element.tap()
        element.typeText(value)
    }

    func shouldBeText(text: String) {
        XCTAssertTrue(self.app.staticTexts[text].waitForExistence(timeout: Self.defaultTimeout), "No text \(text)")
    }

    func confirmAlert(text: String, button: String) {
        let alert = self.app.alerts[text].firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: Self.defaultTimeout), "No alert \(text)")
        alert.buttons[button].tap()
    }
}
