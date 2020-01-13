import UIKit

final class NewSettingsAssembly: Assembly {
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
        let viewController = NewSettingsViewController(interactor: interactor)

        presenter.viewController = viewController

        return viewController
    }
}
