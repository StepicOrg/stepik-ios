import Foundation
import XCTest

final class CatalogTests: BaseTest {
    let onbordingScreen = OnboardingScreen()
    let navigationTabs = MainNavigationTabs()
    let catalogScreen = CatalogScreen()

    override func setUp() {
        CommonActions.App.delete()
        super.setUp()

        self.addUIInterruptionMonitor(
            withDescription: "“\(AppName.name)” Would Like to Send You Notifications"
        ) { alert -> Bool in
            let alertButton = alert.buttons["Allow"]
            if alert.elementType == .alert && alertButton.exists {
                alertButton.tap()
                return true
            }
            return false
        }
    }

    func testUserCanChangeLanguageOnce() throws {
        self.onbordingScreen.closeOnbording()
        self.app.tap()

        self.navigationTabs.openCatalog()
        self.catalogScreen.selectRuLanguage()

        self.app.terminate()
        self.app.launch()

        self.navigationTabs.openCatalog()
        self.catalogScreen.shouldNotBeLanguageButtons()
    }
}
