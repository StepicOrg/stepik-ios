import UIKit

final class NewSettingsAssembly: Assembly {
    private let navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState

    private weak var moduleOutput: NewSettingsOutputProtocol?

    init(
        navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init(),
        moduleOutput: NewSettingsOutputProtocol?
    ) {
        self.navigationBarAppearance = navigationBarAppearance
        self.moduleOutput = moduleOutput
    }

    func makeModule() -> UIViewController {
        let provider = NewSettingsProvider(
            downloadVideoQualityStorageManager: DownloadVideoQualityStorageManager(),
            streamVideoQualityStorageManager: StreamVideoQualityStorageManager(),
            contentLanguageService: ContentLanguageService(),
            stepFontSizeStorageManager: StepFontSizeStorageManager(),
            autoplayStorageManager: AutoplayStorageManager(),
            adaptiveStorageManager: AdaptiveStorageManager.shared,
            downloadsProvider: DownloadsProvider(
                coursesPersistenceService: CoursesPersistenceService(),
                adaptiveStorageManager: AdaptiveStorageManager.shared,
                videoFileManager: VideoStoredFileManager(fileManager: FileManager.default),
                storageUsageService: StorageUsageService(
                    videoFileManager: VideoStoredFileManager(fileManager: FileManager.default)
                )
            )
        )
        let presenter = NewSettingsPresenter()
        let interactor = NewSettingsInteractor(
            presenter: presenter,
            provider: provider,
            userAccountService: UserAccountService()
        )
        let viewController = NewSettingsViewController(
            interactor: interactor,
            appearance: .init(navigationBarAppearance: self.navigationBarAppearance)
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
