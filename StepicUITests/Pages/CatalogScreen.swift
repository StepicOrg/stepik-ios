import Foundation
import XCTest

class CatalogScreen: BaseScreen {
    private lazy var ruButton = app.buttons["Ru"]
    private lazy var enButton = app.buttons["En"]


    func selectRuLanguage() {
        XCTAssertTrue(self.ruButton.waitForExistence(timeout: 10), "No 'Ru' button")
        self.ruButton.tap()
    }

    func selectEnLanguage() {
        XCTAssertTrue(self.enButton.waitForExistence(timeout: 10), "No 'En' button")
        self.enButton.tap()
    }

    func shouldNotBeLanguageButtons() {
        XCTAssertFalse(self.ruButton.waitForExistence(timeout: 5), "'En' button exists")
        XCTAssertFalse(self.enButton.waitForExistence(timeout: 5), "'Ru' button exists")
    }
}
