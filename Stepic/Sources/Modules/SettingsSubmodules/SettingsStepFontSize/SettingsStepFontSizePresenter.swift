import UIKit

protocol SettingsStepFontSizePresenterProtocol {
    func presentFontSizes(response: SettingsStepFontSize.FontSizesLoad.Response)
    func presentFontSizeChange(response: SettingsStepFontSize.FontSizeSelection.Response)
}

final class SettingsStepFontSizePresenter: SettingsStepFontSizePresenterProtocol {
    weak var viewController: SettingsStepFontSizeViewControllerProtocol?

    func presentFontSizes(response: SettingsStepFontSize.FontSizesLoad.Response) {
        var viewModels: [SettingsStepFontSizeViewModel] = []
        for (uid, fontSize) in response.result.availableFontSizes {
            let viewModel = SettingsStepFontSizeViewModel(
                title: fontSize.title,
                isSelected: fontSize == response.result.activeFontSize,
                uniqueIdentifier: uid
            )
            viewModels.append(viewModel)
        }

        let viewModel = SettingsStepFontSize.FontSizesLoad.ViewModel(
            state: SettingsStepFontSize.ViewControllerState.result(data: viewModels)
        )
        self.viewController?.displayFontSizes(viewModel: viewModel)
    }

    func presentFontSizeChange(response: SettingsStepFontSize.FontSizeSelection.Response) {
        var viewModels: [SettingsStepFontSizeViewModel] = []
        for (uid, fontSize) in response.result.availableFontSizes {
            let viewModel = SettingsStepFontSizeViewModel(
                title: fontSize.title,
                isSelected: fontSize == response.result.activeFontSize,
                uniqueIdentifier: uid
            )
            viewModels.append(viewModel)
        }

        let viewModel = SettingsStepFontSize.FontSizeSelection.ViewModel(
            state: SettingsStepFontSize.ViewControllerState.result(data: viewModels)
        )
        self.viewController?.displayFontSizeChange(viewModel: viewModel)
    }
}
