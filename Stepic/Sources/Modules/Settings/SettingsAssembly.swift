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
            useMobileDataForDownloadingStorageManager: UseMobileDataForDownloadingStorageManager(),
            contentLanguageService: ContentLanguageService(),
            stepFontSizeStorageManager: StepFontSizeStorageManager(),
            autoplayStorageManager: AutoplayStorageManager(),
            adaptiveStorageManager: AdaptiveStorageManager.shared,
            downloadsProvider: DownloadsProvider(
                coursesPersistenceService: CoursesPersistenceService(),
                adaptiveStorageManager: AdaptiveStorageManager.shared,
                videoFileManager: VideoStoredFileManager(fileManager: .default),
                imageFileManager: ImageStoredFileManager(fileManager: .default),
                storageUsageService: StorageUsageService(
                    videoFileManager: VideoStoredFileManager(fileManager: .default),
                    imageFileManager: ImageStoredFileManager(fileManager: .default)
                )
            )
        )
        let presenter = SettingsPresenter()
        let interactor = SettingsInteractor(
            presenter: presenter,
            provider: provider,
            userAccountService: UserAccountService()
        )
        let viewController = SettingsViewController(
            interactor: interactor,
            appearance: .init(navigationBarAppearance: self.navigationBarAppearance)
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}
