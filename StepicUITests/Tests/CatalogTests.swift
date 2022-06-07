import Foundation
import XCTest

class CatalogTests: BaseTest {
    let onbordingScreen = OnboardingScreen()
    let navigation = MainNavigationTabs()
    let catalogScreen = CatalogScreen()


    override func setUp() {
        deleteApplication()
        super.setUp()

        addUIInterruptionMonitor(
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
        onbordingScreen.closeOnbording()
        app.tap()
        navigation.openCatalog()
        catalogScreen.selectRuLanguage()
        app.terminate()
        app.launch()
        navigation.openCatalog()
        catalogScreen.shouldNotBeLanguageButtons()
    }
}
