import Foundation
import PromiseKit

protocol SettingsInteractorProtocol {
    func doSettingsLoad(request: Settings.SettingsLoad.Request)
    // DownloadVideoQuality
    func doDownloadVideoQualitySettingPresentation(request: Settings.DownloadVideoQualitySettingPresentation.Request)
    func doDownloadVideoQualitySettingUpdate(request: Settings.DownloadVideoQualitySettingUpdate.Request)
    // StreamVideoQuality
    func doStreamVideoQualitySettingPresentation(request: Settings.StreamVideoQualitySettingPresentation.Request)
    func doStreamVideoQualitySettingUpdate(request: Settings.StreamVideoQualitySettingUpdate.Request)
    // ContentLanguage
    func doContentLanguageSettingPresentation(request: Settings.ContentLanguageSettingPresentation.Request)
    func doContentLanguageSettingUpdate(request: Settings.ContentLanguageSettingUpdate.Request)
    // StepFontSize
    func doStepFontSizeSettingPresentation(request: Settings.StepFontSizeSettingPresentation.Request)
    func doStepFontSizeUpdate(request: Settings.StepFontSizeSettingUpdate.Request)
    // ApplicationTheme
    func doApplicationThemeSettingPresentation(request: Settings.ApplicationThemeSettingPresentation.Request)
    func doApplicationThemeSettingUpdate(request: Settings.ApplicationThemeSettingUpdate.Request)

    func doUseCellularDataForDownloadsSettingUpdate(request: Settings.UseCellularDataForDownloadsSettingUpdate.Request)
    func doAutoplayNextVideoSettingUpdate(request: Settings.AutoplayNextVideoSettingUpdate.Request)
    func doAdaptiveModeSettingUpdate(request: Settings.AdaptiveModeSettingUpdate.Request)
    func doDeleteAllContent(request: Settings.DeleteAllContent.Request)
    func doAccountLogOut(request: Settings.AccountLogOut.Request)
    func doDeleteUserAccountPresentation(request: Settings.DeleteUserAccountPresentation.Request)
}

final class SettingsInteractor: SettingsInteractorProtocol {
    weak var moduleOutput: SettingsOutputProtocol?

    private let presenter: SettingsPresenterProtocol
    private let provider: SettingsProviderProtocol

    private let analytics: Analytics
    private let userAccountService: UserAccountServiceProtocol
    private let remoteConfig: RemoteConfig

    private let downloadsDeletionService: DownloadsDeletionServiceProtocol

    private var settingsData: Settings.SettingsData {
        .init(
            downloadVideoQuality: self.provider.globalDownloadVideoQuality,
            streamVideoQuality: self.provider.globalStreamVideoQuality,
            applicationTheme: self.provider.globalApplicationTheme,
            contentLanguage: self.provider.globalContentLanguage,
            stepFontSize: self.provider.globalStepFontSize,
            shouldUseCellularDataForDownloads: self.provider.shouldUseCellularDataForDownloads,
            isAutoplayEnabled: self.provider.isAutoplayEnabled,
            isAdaptiveModeEnabled: self.provider.isAdaptiveModeEnabled,
            isDarkModeAvailable: self.remoteConfig.isDarkModeAvailable,
            isAuthorized: self.isAuthorized
        )
    }

    private var isAuthorized: Bool {
        !(self.userAccountService.currentUser?.isGuest ?? true) && self.userAccountService.isAuthorized
    }

    var shouldCheckUserAccountDeletionResult = false

    init(
        presenter: SettingsPresenterProtocol,
        provider: SettingsProviderProtocol,
        analytics: Analytics,
        userAccountService: UserAccountServiceProtocol,
        remoteConfig: RemoteConfig,
        downloadsDeletionService: DownloadsDeletionServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
        self.userAccountService = userAccountService
        self.remoteConfig = remoteConfig
        self.downloadsDeletionService = downloadsDeletionService
    }

    func doSettingsLoad(request: Settings.SettingsLoad.Request) {
        self.checkUserAccountIsDeletedIfNeeded()
        self.presenter.presentSettings(response: .init(data: self.settingsData))
    }

    func doDownloadVideoQualitySettingPresentation(request: Settings.DownloadVideoQualitySettingPresentation.Request) {
        self.presenter.presentDownloadVideoQualitySetting(
            response: .init(
                availableDownloadVideoQualities: self.provider.availableDownloadVideoQualities,
                globalDownloadVideoQuality: self.provider.globalDownloadVideoQuality
            )
        )
    }

    func doDownloadVideoQualitySettingUpdate(request: Settings.DownloadVideoQualitySettingUpdate.Request) {
        if let newDownloadVideoQuality = DownloadVideoQuality(uniqueIdentifier: request.setting.uniqueIdentifier) {
            self.provider.globalDownloadVideoQuality = newDownloadVideoQuality
        }
    }

    func doStreamVideoQualitySettingPresentation(request: Settings.StreamVideoQualitySettingPresentation.Request) {
        self.presenter.presentStreamVideoQualitySetting(
            response: .init(
                availableStreamVideoQualities: self.provider.availableStreamVideoQualities,
                globalStreamVideoQuality: self.provider.globalStreamVideoQuality
            )
        )
    }

    func doStreamVideoQualitySettingUpdate(request: Settings.StreamVideoQualitySettingUpdate.Request) {
        if let newStreamVideoQuality = StreamVideoQuality(uniqueIdentifier: request.setting.uniqueIdentifier) {
            self.provider.globalStreamVideoQuality = newStreamVideoQuality
        }
    }

    func doContentLanguageSettingPresentation(request: Settings.ContentLanguageSettingPresentation.Request) {
        self.presenter.presentContentLanguageSetting(
            response: .init(
                availableContentLanguages: self.provider.availableContentLanguages,
                globalContentLanguage: self.provider.globalContentLanguage
            )
        )
    }

    func doContentLanguageSettingUpdate(request: Settings.ContentLanguageSettingUpdate.Request) {
        let selectedContentLanguage = ContentLanguage(languageString: request.setting.uniqueIdentifier)
        self.provider.globalContentLanguage = selectedContentLanguage
        self.analytics.send(.contentLanguageChanged(selectedContentLanguage, source: .settings))
    }

    func doStepFontSizeSettingPresentation(request: Settings.StepFontSizeSettingPresentation.Request) {
        self.presenter.presentStepFontSizeSetting(
            response: .init(
                availableStepFontSizes: self.provider.availableStepFontSizes,
                globalStepFontSize: self.provider.globalStepFontSize
            )
        )
    }

    func doStepFontSizeUpdate(request: Settings.StepFontSizeSettingUpdate.Request) {
        if let newStepFontSize = StepFontSize(uniqueIdentifier: request.setting.uniqueIdentifier) {
            self.analytics.send(.settingsStepFontSizeSelected(newStepFontSize))
            self.provider.globalStepFontSize = newStepFontSize
        }
    }

    func doApplicationThemeSettingPresentation(request: Settings.ApplicationThemeSettingPresentation.Request) {
        self.presenter.presentApplicationThemeSetting(
            response: .init(
                availableApplicationThemes: self.provider.availableApplicationThemes,
                currentApplicationTheme: self.provider.globalApplicationTheme
            )
        )
    }

    func doApplicationThemeSettingUpdate(request: Settings.ApplicationThemeSettingUpdate.Request) {
        if let newApplicationTheme = ApplicationTheme(uniqueIdentifier: request.setting.uniqueIdentifier) {
            self.provider.globalApplicationTheme = newApplicationTheme
        }
    }

    func doUseCellularDataForDownloadsSettingUpdate(
        request: Settings.UseCellularDataForDownloadsSettingUpdate.Request
    ) {
        self.provider.shouldUseCellularDataForDownloads = request.isOn
    }

    func doAutoplayNextVideoSettingUpdate(request: Settings.AutoplayNextVideoSettingUpdate.Request) {
        self.provider.isAutoplayEnabled = request.isOn
    }

    func doAdaptiveModeSettingUpdate(request: Settings.AdaptiveModeSettingUpdate.Request) {
        self.provider.isAdaptiveModeEnabled = request.isOn
    }

    func doDeleteAllContent(request: Settings.DeleteAllContent.Request) {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly {
            // For better waiting animation.
            after(.seconds(1))
        }.then {
            self.downloadsDeletionService.deleteAllDownloads()
        }.done {
            self.presenter.presentDeleteAllContentResult(response: .init(isSuccessful: true))
        }.catch { _ in
            self.presenter.presentDeleteAllContentResult(response: .init(isSuccessful: false))
        }
    }

    func doAccountLogOut(request: Settings.AccountLogOut.Request) {
        DispatchQueue.main.async {
            self.userAccountService.logOut()
            self.moduleOutput?.handleUserLoggedOut()
            self.presenter.presentDismiss(response: .init())
        }
    }

    func doDeleteUserAccountPresentation(request: Settings.DeleteUserAccountPresentation.Request) {
        self.analytics.send(.deleteAccountClicked)
        self.shouldCheckUserAccountDeletionResult = true
        self.presenter.presentDeleteUserAccount(response: .init())
    }

    private func checkUserAccountIsDeletedIfNeeded() {
        guard self.shouldCheckUserAccountDeletionResult,
              let currentUserID = self.userAccountService.currentUserID else {
            return
        }

        self.shouldCheckUserAccountDeletionResult = false

        self.provider.fetchCurrentUser().done { remoteCurrentUser in
            if currentUserID != remoteCurrentUser.id {
                self.doAccountLogOut(request: .init())
            }
        }.cauterize()
    }
}
