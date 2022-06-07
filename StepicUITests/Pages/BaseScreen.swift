import Foundation
import XCTest

class BaseScreen {
    var app = XCUIApplication()

    func typeText(element: XCUIElement, value: String) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "No field \(element)")
        element.tap()
        element.typeText(value)
    }

    func shouldBeText(text: String) {
        XCTAssertTrue(app.staticTexts[text].waitForExistence(timeout: 10), "No text \(text)")
    }

    func confirmAlert(text: String, button: String) {
        let alert = app.alerts[text].firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10), "No alert \(text)")
        alert.buttons[button].tap()
    }
}
