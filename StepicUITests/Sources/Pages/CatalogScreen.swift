import Foundation
import XCTest

final class CatalogScreen: BaseScreen {
    private lazy var ruButton = self.app.buttons["Ru"]
    private lazy var enButton = self.app.buttons["En"]

    func selectRuLanguage() {
        XCTAssertTrue(self.ruButton.waitForExistence(timeout: Self.defaultTimeout), "No 'Ru' button")
        self.ruButton.tap()
    }

    func selectEnLanguage() {
        XCTAssertTrue(self.enButton.waitForExistence(timeout: Self.defaultTimeout), "No 'En' button")
        self.enButton.tap()
    }

    func shouldNotBeLanguageButtons() {
        XCTAssertFalse(self.ruButton.waitForExistence(timeout: Self.smallTimeout), "'En' button exists")
        XCTAssertFalse(self.enButton.waitForExistence(timeout: Self.smallTimeout), "'Ru' button exists")
    }
}
