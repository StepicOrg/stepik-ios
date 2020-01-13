import UIKit

protocol NewSettingsPresenterProtocol {
    func presentSettings(response: NewSettings.SettingsLoad.Response)
}

final class NewSettingsPresenter: NewSettingsPresenterProtocol {
    weak var viewController: NewSettingsViewControllerProtocol?

    func presentSettings(response: NewSettings.SettingsLoad.Response) {
        let formattedDownloadVideoQuality = FormatterHelper.downloadVideoQualityInProgressiveScan(
            response.downloadVideoQuality
        )
        let formattedStreamVideoQuality = FormatterHelper.streamVideoQualityInProgressiveScan(
            response.streamVideoQuality
        )

        let settingsViewModel = NewSettingsViewModel(
            downloadVideoQuality: formattedDownloadVideoQuality,
            streamVideoQuality: formattedStreamVideoQuality,
            contentLanguage: response.contentLanguage.fullString,
            stepFontSize: response.stepFontSize.title,
            isAutoplayEnabled: response.isAutoplayEnabled,
            isAdaptiveModeEnabled: response.isAdaptiveModeEnabled
        )

        self.viewController?.displaySettings(viewModel: .init(viewModel: settingsViewModel))
    }
}
