import Foundation
import XCTest

class OnboardingScreen: BaseScreen {
    private lazy var closeButton = app.navigationBars.buttons[AccessibilityIdentifiers.Onboarding.closeButton]
    private lazy var nextButton = app.buttons[AccessibilityIdentifiers.Onboarding.nextButton]


    func closeOnbording() {
        XCTAssertTrue(self.closeButton.waitForExistence(timeout: 10), "No 'Close' button")
        self.closeButton.tap()
    }

    func next() {
        XCTAssertTrue(self.nextButton.waitForExistence(timeout: 10), "No 'Next' button")
        self.nextButton.tap()
    }
}
