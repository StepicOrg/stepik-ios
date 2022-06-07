import Foundation
import XCTest

final class MainNavigationTabs: BaseScreen {
    private lazy var profileTab = self.app.tabBars.buttons[AccessibilityIdentifiers.TabBar.profile]
    private lazy var catalogTab = self.app.tabBars.buttons[AccessibilityIdentifiers.TabBar.catalog]

    func openProfile() {
        XCTAssertTrue(self.profileTab.waitForExistence(timeout: Self.defaultTimeout), "No 'Profile' tab")
        self.profileTab.tap()
    }

    func openCatalog() {
        XCTAssertTrue(self.catalogTab.waitForExistence(timeout: Self.defaultTimeout), "No 'Catalog' tab")
        self.catalogTab.tap()
    }
}
