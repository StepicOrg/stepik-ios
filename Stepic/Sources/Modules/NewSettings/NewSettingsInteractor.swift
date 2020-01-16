import Foundation
import PromiseKit

protocol NewSettingsInteractorProtocol {
    func doSettingsLoad(request: NewSettings.SettingsLoad.Request)
    // DownloadVideoQuality
    func doDownloadVideoQualityPresentation(request: NewSettings.DownloadVideoQualityPresentation.Request)
    func doDownloadVideoQualityUpdate(request: NewSettings.DownloadVideoQualityUpdate.Request)
    // StreamVideoQuality
    func doStreamVideoQualityPresentation(request: NewSettings.StreamVideoQualityPresentation.Request)
    func doStreamVideoQualityUpdate(request: NewSettings.StreamVideoQualityUpdate.Request)
    // ContentLanguage
    func doContentLanguagePresentation(request: NewSettings.ContentLanguagePresentation.Request)
    func doContentLanguageUpdate(request: NewSettings.ContentLanguageUpdate.Request)
    // StepFontSize
    func doStepFontSizePresentation(request: NewSettings.StepFontSizePresentation.Request)
    func doStepFontSizeUpdate(request: NewSettings.StepFontSizeUpdate.Request)
}

final class NewSettingsInteractor: NewSettingsInteractorProtocol {
    private let presenter: NewSettingsPresenterProtocol
    private let provider: NewSettingsProviderProtocol

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
        provider: NewSettingsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSettingsLoad(request: NewSettings.SettingsLoad.Request) {
        self.presenter.presentSettings(response: .init(data: self.settingsData))
    }

    func doDownloadVideoQualityPresentation(request: NewSettings.DownloadVideoQualityPresentation.Request) {
        self.presenter.presentDownloadVideoQualitySetting(
            response: .init(
                availableDownloadVideoQualities: self.provider.availableDownloadVideoQualities,
                globalDownloadVideoQuality: self.provider.globalDownloadVideoQuality
            )
        )
    }

    func doDownloadVideoQualityUpdate(request: NewSettings.DownloadVideoQualityUpdate.Request) {
        if let newDownloadVideoQuality = DownloadVideoQuality(qualityString: request.setting.uniqueIdentifier) {
            self.provider.globalDownloadVideoQuality = newDownloadVideoQuality
        }
    }

    func doStreamVideoQualityPresentation(request: NewSettings.StreamVideoQualityPresentation.Request) {
        self.presenter.presentStreamVideoQualitySetting(
            response: .init(
                availableStreamVideoQualities: self.provider.availableStreamVideoQualities,
                globalStreamVideoQuality: self.provider.globalStreamVideoQuality
            )
        )
    }

    func doStreamVideoQualityUpdate(request: NewSettings.StreamVideoQualityUpdate.Request) {
        if let newStreamVideoQuality = StreamVideoQuality(qualityString: request.setting.uniqueIdentifier) {
            self.provider.globalStreamVideoQuality = newStreamVideoQuality
        }
    }

    func doContentLanguagePresentation(request: NewSettings.ContentLanguagePresentation.Request) {
        self.presenter.presentContentLanguageSetting(
            response: .init(
                availableContentLanguages: self.provider.availableContentLanguages,
                globalContentLanguage: self.provider.globalContentLanguage
            )
        )
    }

    func doContentLanguageUpdate(request: NewSettings.ContentLanguageUpdate.Request) {
        self.provider.globalContentLanguage = ContentLanguage(languageString: request.setting.uniqueIdentifier)
    }

    func doStepFontSizePresentation(request: NewSettings.StepFontSizePresentation.Request) {
        self.presenter.presentStepFontSizeSetting(
            response: .init(
                availableStepFontSizes: self.provider.availableStepFontSizes,
                globalStepFontSize: self.provider.globalStepFontSize
            )
        )
    }

    func doStepFontSizeUpdate(request: NewSettings.StepFontSizeUpdate.Request) {
        if let newStepFontSize = StepFontSize(uniqueIdentifier: request.setting.uniqueIdentifier) {
            self.provider.globalStepFontSize = newStepFontSize
        }
    }
}
