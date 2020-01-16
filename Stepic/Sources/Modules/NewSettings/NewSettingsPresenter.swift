import UIKit

protocol NewSettingsPresenterProtocol {
    func presentSettings(response: NewSettings.SettingsLoad.Response)
    func presentDownloadVideoQualitySetting(response: NewSettings.DownloadVideoQualityPresentation.Response)
    func presentStreamVideoQualitySetting(response: NewSettings.StreamVideoQualityPresentation.Response)
    func presentContentLanguageSetting(response: NewSettings.ContentLanguagePresentation.Response)
    func presentStepFontSizeSetting(response: NewSettings.StepFontSizePresentation.Response)

    func presentDeleteAllContentResult(response: NewSettings.DeleteAllContent.Response)
    func presentWaitingState(response: NewSettings.BlockingWaitingIndicatorUpdate.Response)
}

final class NewSettingsPresenter: NewSettingsPresenterProtocol {
    weak var viewController: NewSettingsViewControllerProtocol?

    func presentSettings(response: NewSettings.SettingsLoad.Response) {
        let settingsViewModel = self.makeViewModel(from: response.data)
        self.viewController?.displaySettings(viewModel: .init(viewModel: settingsViewModel))
    }

    func presentDownloadVideoQualitySetting(response: NewSettings.DownloadVideoQualityPresentation.Response) {
        let settingDescription = NewSettings.SettingDescription(
            settings: response.availableDownloadVideoQualities.map {
                .init(uniqueIdentifier: $0.description, title: FormatterHelper.humanReadableDownloadVideoQuality($0))
            },
            currentSetting: .init(
                uniqueIdentifier: response.globalDownloadVideoQuality.description,
                title: FormatterHelper.humanReadableDownloadVideoQuality(response.globalDownloadVideoQuality)
            )
        )

        self.viewController?.displayDownloadVideoQualitySetting(
            viewModel: .init(settingDescription: settingDescription)
        )
    }

    func presentStreamVideoQualitySetting(response: NewSettings.StreamVideoQualityPresentation.Response) {
        let settingDescription = NewSettings.SettingDescription(
            settings: response.availableStreamVideoQualities.map {
                .init(uniqueIdentifier: $0.description, title: FormatterHelper.humanReadableStreamVideoQuality($0))
            },
            currentSetting: .init(
                uniqueIdentifier: response.globalStreamVideoQuality.description,
                title: FormatterHelper.humanReadableStreamVideoQuality(response.globalStreamVideoQuality)
            )
        )

        self.viewController?.displayStreamVideoQualitySetting(viewModel: .init(settingDescription: settingDescription))
    }

    func presentContentLanguageSetting(response: NewSettings.ContentLanguagePresentation.Response) {
        let settingDescription = NewSettings.SettingDescription(
            settings: response.availableContentLanguages.map {
                .init(uniqueIdentifier: $0.languageString, title: $0.fullString)
            },
            currentSetting: .init(
                uniqueIdentifier: response.globalContentLanguage.languageString,
                title: response.globalContentLanguage.fullString
            )
        )

        self.viewController?.displayContentLanguageSetting(viewModel: .init(settingDescription: settingDescription))
    }

    func presentStepFontSizeSetting(response: NewSettings.StepFontSizePresentation.Response) {
        let settingDescription = NewSettings.SettingDescription(
            settings: response.availableStepFontSizes.map {
                .init(uniqueIdentifier: $0.uniqueIdentifier, title: $0.title)
            },
            currentSetting: .init(
                uniqueIdentifier: response.globalStepFontSize.uniqueIdentifier,
                title: response.globalStepFontSize.title
            )
        )

        self.viewController?.displayStepFontSizeSetting(viewModel: .init(settingDescription: settingDescription))
    }

    func presentDeleteAllContentResult(response: NewSettings.DeleteAllContent.Response) {
        self.viewController?.displayDeleteAllContentResult(viewModel: .init(isSuccessful: response.isSuccessful))
    }

    func presentWaitingState(response: NewSettings.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    // MARK: Private API

    private func makeViewModel(from data: NewSettings.SettingsData) -> NewSettingsViewModel {
        return NewSettingsViewModel(
            downloadVideoQuality: FormatterHelper.downloadVideoQualityInProgressiveScan(data.downloadVideoQuality),
            streamVideoQuality: FormatterHelper.streamVideoQualityInProgressiveScan(data.streamVideoQuality),
            contentLanguage: data.contentLanguage.fullString,
            stepFontSize: data.stepFontSize.title,
            isAutoplayEnabled: data.isAutoplayEnabled,
            isAdaptiveModeEnabled: data.isAdaptiveModeEnabled
        )
    }
}
