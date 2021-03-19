import UIKit

protocol SettingsPresenterProtocol {
    func presentSettings(response: Settings.SettingsLoad.Response)
    func presentDownloadVideoQualitySetting(response: Settings.DownloadVideoQualitySettingPresentation.Response)
    func presentStreamVideoQualitySetting(response: Settings.StreamVideoQualitySettingPresentation.Response)
    func presentApplicationThemeSetting(response: Settings.ApplicationThemeSettingPresentation.Response)
    func presentContentLanguageSetting(response: Settings.ContentLanguageSettingPresentation.Response)
    func presentStepFontSizeSetting(response: Settings.StepFontSizeSettingPresentation.Response)
    func presentDeleteAllContentResult(response: Settings.DeleteAllContent.Response)
    func presentWaitingState(response: Settings.BlockingWaitingIndicatorUpdate.Response)
    func presentDismiss(response: Settings.DismissPresentation.Response)
}

final class SettingsPresenter: SettingsPresenterProtocol {
    weak var viewController: SettingsViewControllerProtocol?

    func presentSettings(response: Settings.SettingsLoad.Response) {
        let settingsViewModel = self.makeViewModel(from: response.data)
        self.viewController?.displaySettings(viewModel: .init(viewModel: settingsViewModel))
    }

    func presentDownloadVideoQualitySetting(response: Settings.DownloadVideoQualitySettingPresentation.Response) {
        let settingDescription = Settings.SettingDescription(
            settings: response.availableDownloadVideoQualities.map {
                .init(
                    uniqueIdentifier: $0.uniqueIdentifier,
                    title: FormatterHelper.humanReadableDownloadVideoQuality($0)
                )
            },
            currentSetting: .init(
                uniqueIdentifier: response.globalDownloadVideoQuality.uniqueIdentifier,
                title: FormatterHelper.humanReadableDownloadVideoQuality(response.globalDownloadVideoQuality)
            )
        )

        self.viewController?.displayDownloadVideoQualitySetting(
            viewModel: .init(settingDescription: settingDescription)
        )
    }

    func presentStreamVideoQualitySetting(response: Settings.StreamVideoQualitySettingPresentation.Response) {
        let settingDescription = Settings.SettingDescription(
            settings: response.availableStreamVideoQualities.map {
                .init(uniqueIdentifier: $0.uniqueIdentifier, title: FormatterHelper.humanReadableStreamVideoQuality($0))
            },
            currentSetting: .init(
                uniqueIdentifier: response.globalStreamVideoQuality.uniqueIdentifier,
                title: FormatterHelper.humanReadableStreamVideoQuality(response.globalStreamVideoQuality)
            )
        )

        self.viewController?.displayStreamVideoQualitySetting(viewModel: .init(settingDescription: settingDescription))
    }

    func presentApplicationThemeSetting(response: Settings.ApplicationThemeSettingPresentation.Response) {
        let settingDescription = Settings.SettingDescription(
            settings: response.availableApplicationThemes.map {
                .init(uniqueIdentifier: $0.uniqueIdentifier, title: $0.title)
            },
            currentSetting: .init(
                uniqueIdentifier: response.currentApplicationTheme.uniqueIdentifier,
                title: response.currentApplicationTheme.title
            )
        )

        self.viewController?.displayApplicationThemeSetting(viewModel: .init(settingDescription: settingDescription))
    }

    func presentContentLanguageSetting(response: Settings.ContentLanguageSettingPresentation.Response) {
        let settingDescription = Settings.SettingDescription(
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

    func presentStepFontSizeSetting(response: Settings.StepFontSizeSettingPresentation.Response) {
        let settingDescription = Settings.SettingDescription(
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

    func presentDeleteAllContentResult(response: Settings.DeleteAllContent.Response) {
        self.viewController?.displayDeleteAllContentResult(viewModel: .init(isSuccessful: response.isSuccessful))
    }

    func presentWaitingState(response: Settings.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentDismiss(response: Settings.DismissPresentation.Response) {
        self.viewController?.displayDismiss(viewModel: .init())
    }

    // MARK: Private API

    private func makeViewModel(from data: Settings.SettingsData) -> SettingsViewModel {
        SettingsViewModel(
            downloadVideoQuality: FormatterHelper.downloadVideoQualityInProgressiveScan(data.downloadVideoQuality),
            streamVideoQuality: FormatterHelper.streamVideoQualityInProgressiveScan(data.streamVideoQuality),
            applicationTheme: data.applicationTheme.title,
            contentLanguage: data.contentLanguage.fullString,
            stepFontSize: data.stepFontSize.title,
            shouldUseCellularDataForDownloads: data.shouldUseCellularDataForDownloads,
            isAutoplayEnabled: data.isAutoplayEnabled,
            isAdaptiveModeEnabled: data.isAdaptiveModeEnabled,
            isApplicationThemeSettingAvailable: data.isDarkModeAvailable,
            isAuthorized: data.isAuthorized
        )
    }
}
