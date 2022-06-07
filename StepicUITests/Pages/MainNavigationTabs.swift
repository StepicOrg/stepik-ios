import Foundation
import XCTest

class MainNavigationTabs: BaseScreen {
    private lazy var profileTab = app.tabBars.buttons[AccessibilityIdentifiers.TabBar.profile]
    private lazy var catalogTab = app.tabBars.buttons[AccessibilityIdentifiers.TabBar.catalog]

    func openProfile() {
        XCTAssertTrue(self.profileTab.waitForExistence(timeout: 10), "No 'Profile' tab")
        self.profileTab.tap()
    }

    func openCatalog() {
        XCTAssertTrue(self.catalogTab.waitForExistence(timeout: 10), "No 'Catalog' tab")
        self.catalogTab.tap()
    }
}
