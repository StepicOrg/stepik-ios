import UIKit

final class NewSettingsAssembly: Assembly {
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    init(navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()) {
        self.navigationBarAppearance = navigationBarAppearance
    }

    func makeModule() -> UIViewController {
        let provider = NewSettingsProvider(
            downloadVideoQualityStorageManager: DownloadVideoQualityStorageManager(),
            streamVideoQualityStorageManager: StreamVideoQualityStorageManager(),
            contentLanguageService: ContentLanguageService(),
            stepFontSizeStorageManager: StepFontSizeStorageManager(),
            autoplayStorageManager: AutoplayStorageManager(),
            adaptiveStorageManager: AdaptiveStorageManager.shared
        )
        let presenter = NewSettingsPresenter()
        let interactor = NewSettingsInteractor(presenter: presenter, provider: provider)
        let viewController = NewSettingsViewController(
            interactor: interactor,
            appearance: .init(navigationBarAppearance: self.navigationBarAppearance)
        )

        presenter.viewController = viewController

        return viewController
    }
}
