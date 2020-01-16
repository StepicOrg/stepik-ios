import Foundation
import PromiseKit

protocol NewSettingsInteractorProtocol {
    func doSettingsLoad(request: NewSettings.SettingsLoad.Request)
    // DownloadVideoQuality
    func doDownloadVideoQualitySettingPresentation(request: NewSettings.DownloadVideoQualitySettingPresentation.Request)
    func doDownloadVideoQualitySettingUpdate(request: NewSettings.DownloadVideoQualitySettingUpdate.Request)
    // StreamVideoQuality
    func doStreamVideoQualitySettingPresentation(request: NewSettings.StreamVideoQualitySettingPresentation.Request)
    func doStreamVideoQualitySettingUpdate(request: NewSettings.StreamVideoQualitySettingUpdate.Request)
    // ContentLanguage
    func doContentLanguageSettingPresentation(request: NewSettings.ContentLanguageSettingPresentation.Request)
    func doContentLanguageSettingUpdate(request: NewSettings.ContentLanguageSettingUpdate.Request)
    // StepFontSize
    func doStepFontSizeSettingPresentation(request: NewSettings.StepFontSizeSettingPresentation.Request)
    func doStepFontSizeUpdate(request: NewSettings.StepFontSizeSettingUpdate.Request)

    func doAutoplayNextVideoSettingUpdate(request: NewSettings.AutoplayNextVideoSettingUpdate.Request)
    func doAdaptiveModeSettingUpdate(request: NewSettings.AdaptiveModeSettingUpdate.Request)
    func doDeleteAllContent(request: NewSettings.DeleteAllContent.Request)
    func doLogOutOfAccount(request: NewSettings.AccountLogOut.Request)
}

final class NewSettingsInteractor: NewSettingsInteractorProtocol {
    weak var moduleOutput: NewSettingsOutputProtocol?

    private let presenter: NewSettingsPresenterProtocol
    private let provider: NewSettingsProviderProtocol

    private let userAccountService: UserAccountServiceProtocol

    private var settingsData: NewSettings.SettingsData {
        .init(
            downloadVideoQuality: self.provider.globalDownloadVideoQuality,
            streamVideoQuality: self.provider.globalStreamVideoQuality,
            contentLanguage: self.provider.globalContentLanguage,
            stepFontSize: self.provider.globalStepFontSize,
            isAutoplayEnabled: self.provider.isAutoplayEnabled,
            isAdaptiveModeEnabled: self.provider.isAdaptiveModeEnabled
        )
    }

    init(
        presenter: NewSettingsPresenterProtocol,
        provider: NewSettingsProviderProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
    }

    func doSettingsLoad(request: NewSettings.SettingsLoad.Request) {
        self.presenter.presentSettings(response: .init(data: self.settingsData))
    }

    func doDownloadVideoQualitySettingPresentation(
        request: NewSettings.DownloadVideoQualitySettingPresentation.Request
    ) {
        self.presenter.presentDownloadVideoQualitySetting(
            response: .init(
                availableDownloadVideoQualities: self.provider.availableDownloadVideoQualities,
                globalDownloadVideoQuality: self.provider.globalDownloadVideoQuality
            )
        )
    }

    func doDownloadVideoQualitySettingUpdate(request: NewSettings.DownloadVideoQualitySettingUpdate.Request) {
        if let newDownloadVideoQuality = DownloadVideoQuality(qualityString: request.setting.uniqueIdentifier) {
            self.provider.globalDownloadVideoQuality = newDownloadVideoQuality
        }
    }

    func doStreamVideoQualitySettingPresentation(request: NewSettings.StreamVideoQualitySettingPresentation.Request) {
        self.presenter.presentStreamVideoQualitySetting(
            response: .init(
                availableStreamVideoQualities: self.provider.availableStreamVideoQualities,
                globalStreamVideoQuality: self.provider.globalStreamVideoQuality
            )
        )
    }

    func doStreamVideoQualitySettingUpdate(request: NewSettings.StreamVideoQualitySettingUpdate.Request) {
        if let newStreamVideoQuality = StreamVideoQuality(qualityString: request.setting.uniqueIdentifier) {
            self.provider.globalStreamVideoQuality = newStreamVideoQuality
        }
    }

    func doContentLanguageSettingPresentation(request: NewSettings.ContentLanguageSettingPresentation.Request) {
        self.presenter.presentContentLanguageSetting(
            response: .init(
                availableContentLanguages: self.provider.availableContentLanguages,
                globalContentLanguage: self.provider.globalContentLanguage
            )
        )
    }

    func doContentLanguageSettingUpdate(request: NewSettings.ContentLanguageSettingUpdate.Request) {
        self.provider.globalContentLanguage = ContentLanguage(languageString: request.setting.uniqueIdentifier)
    }

    func doStepFontSizeSettingPresentation(request: NewSettings.StepFontSizeSettingPresentation.Request) {
        self.presenter.presentStepFontSizeSetting(
            response: .init(
                availableStepFontSizes: self.provider.availableStepFontSizes,
                globalStepFontSize: self.provider.globalStepFontSize
            )
        )
    }

    func doStepFontSizeUpdate(request: NewSettings.StepFontSizeSettingUpdate.Request) {
        if let newStepFontSize = StepFontSize(uniqueIdentifier: request.setting.uniqueIdentifier) {
            self.provider.globalStepFontSize = newStepFontSize
        }
    }

    func doAutoplayNextVideoSettingUpdate(request: NewSettings.AutoplayNextVideoSettingUpdate.Request) {
        self.provider.isAutoplayEnabled = request.isOn
    }

    func doAdaptiveModeSettingUpdate(request: NewSettings.AdaptiveModeSettingUpdate.Request) {
        self.provider.isAdaptiveModeEnabled = request.isOn
    }

    func doDeleteAllContent(request: NewSettings.DeleteAllContent.Request) {
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly {
            // For better waiting animation.
            after(.seconds(1))
        }.then {
            self.provider.deleteAllDownloadedContent()
        }.done {
            self.presenter.presentDeleteAllContentResult(response: .init(isSuccessful: true))
        }.catch { _ in
            self.presenter.presentDeleteAllContentResult(response: .init(isSuccessful: false))
        }
    }

    func doLogOutOfAccount(request: NewSettings.AccountLogOut.Request) {
        DispatchQueue.main.async {
            self.userAccountService.logOut()
            self.moduleOutput?.handleLoggedOut()
        }
    }
}
