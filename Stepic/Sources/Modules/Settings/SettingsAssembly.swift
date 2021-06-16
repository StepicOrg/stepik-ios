import UIKit

final class SettingsAssembly: Assembly {
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: SettingsOutputProtocol?

    init(
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        moduleOutput: SettingsOutputProtocol? = nil
    ) {
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = moduleOutput
    }

    func makeModule() -> UIViewController {
        let provider = SettingsProvider(
            downloadVideoQualityStorageManager: DownloadVideoQualityStorageManager(),
            streamVideoQualityStorageManager: StreamVideoQualityStorageManager(),
            useCellularDataForDownloadsStorageManager: UseCellularDataForDownloadsStorageManager(),
            contentLanguageService: ContentLanguageService(),
            stepFontSizeStorageManager: StepFontSizeStorageManager(),
            autoplayStorageManager: AutoplayStorageManager(),
            adaptiveStorageManager: AdaptiveStorageManager.shared,
            applicationThemeService: ApplicationThemeService()
        )
        let presenter = SettingsPresenter(urlFactory: StepikURLFactory())
        let interactor = SettingsInteractor(
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared,
            userAccountService: UserAccountService(),
            remoteConfig: .shared,
            downloadsDeletionService: DownloadsDeletionService()
        )
        let viewController = SettingsViewController(
            interactor: interactor,
            analytics: StepikAnalytics.shared,
            appearance: .init(navigationBarAppearance: self.navigationBarAppearance)
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
