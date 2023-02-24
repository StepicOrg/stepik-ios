import Foundation
import XCTest

final class OnboardingScreen: BaseScreen {
    private lazy var closeButton = self.app.navigationBars.buttons[AccessibilityIdentifiers.Onboarding.closeButton]
    private lazy var nextButton = self.app.buttons[AccessibilityIdentifiers.Onboarding.nextButton]

    func closeOnbording() {
        XCTAssertTrue(self.closeButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Close' button")
        self.closeButton.tap()
    }

    func next() {
        XCTAssertTrue(self.nextButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Next' button")
        self.nextButton.tap()
    }
}
