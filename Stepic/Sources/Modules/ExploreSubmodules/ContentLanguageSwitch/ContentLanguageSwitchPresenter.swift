import UIKit

protocol ContentLanguageSwitchPresenterProtocol {
    func presentLanguages(response: ContentLanguageSwitch.LanguagesLoad.Response)
    func presentLanguageChange(response: ContentLanguageSwitch.LanguageSelection.Response)
}

final class ContentLanguageSwitchPresenter: ContentLanguageSwitchPresenterProtocol {
    weak var viewController: ContentLanguageSwitchViewControllerProtocol?

    func presentLanguages(response: ContentLanguageSwitch.LanguagesLoad.Response) {
        var viewModels: [ContentLanguageSwitchViewModel] = []
        for (uid, language) in response.result.availableContentLanguages {
            let viewModel = ContentLanguageSwitchViewModel(
                title: language.displayingString,
                isSelected: language == response.result.activeContentLanguage,
                uniqueIdentifier: uid
            )
            viewModels.append(viewModel)
        }

        let viewModel = ContentLanguageSwitch.LanguagesLoad.ViewModel(
            state: ContentLanguageSwitch.ViewControllerState.result(data: viewModels)
        )
        self.viewController?.displayLanguages(viewModel: viewModel)
    }

    func presentLanguageChange(response: ContentLanguageSwitch.LanguageSelection.Response) {
        var viewModels: [ContentLanguageSwitchViewModel] = []
        for (uid, language) in response.result.availableContentLanguages {
            let viewModel = ContentLanguageSwitchViewModel(
                title: language.displayingString,
                isSelected: language == response.result.activeContentLanguage,
                uniqueIdentifier: uid
            )
            viewModels.append(viewModel)
        }

        let viewModel = ContentLanguageSwitch.LanguageSelection.ViewModel(
            state: ContentLanguageSwitch.ViewControllerState.result(data: viewModels)
        )
        self.viewController?.displayLanguageChange(viewModel: viewModel)
    }
}
