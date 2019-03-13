import Foundation
import PromiseKit

protocol ContentLanguageSwitchInteractorProtocol {
    func doLanguagesListPresentation(request: ContentLanguageSwitch.LanguagesLoad.Request)
    func doLanguageSelection(request: ContentLanguageSwitch.LanguageSelection.Request)
}

final class ContentLanguageSwitchInteractor: ContentLanguageSwitchInteractorProtocol {
    private let presenter: ContentLanguageSwitchPresenterProtocol
    private let provider: ContentLanguageSwitchProviderProtocol

    private var currentAvailableContentLanguages: [(UniqueIdentifierType, ContentLanguage)] = []

    init(
        presenter: ContentLanguageSwitchPresenterProtocol,
        provider: ContentLanguageSwitchProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doLanguagesListPresentation(request: ContentLanguageSwitch.LanguagesLoad.Request) {
        when(
            fulfilled: self.provider.fetchAvailableLanguages(),
            self.provider.fetchCurrentLanguage()
        ).done { (availableContentLanguages, currentContentLanguage) in
            let languages = availableContentLanguages.map {
                language -> (UniqueIdentifierType, ContentLanguage) in
                (language.languageString, language)
            }

            self.currentAvailableContentLanguages = languages
            self.presenter.presentLanguages(
                response: ContentLanguageSwitch.LanguagesLoad.Response(
                    result: ContentLanguageSwitch.ContentLanguageInfo(
                        availableContentLanguages: languages,
                        activeContentLanguage: currentContentLanguage
                    )
                )
            )
        }.catch { _ in
            fatalError("Unexpected error while extracting info about languages")
        }
    }

    func doLanguageSelection(request: ContentLanguageSwitch.LanguageSelection.Request) {
        guard let selectedLanguage = self.currentAvailableContentLanguages
            .first(where: { $0.0 == request.viewModelUniqueIdentifier })?.1 else {
            fatalError("Request contains invalid data")
        }

        self.provider.setGlobalContentLanguage(selectedLanguage)
        self.presenter.presentLanguageChange(
            response: ContentLanguageSwitch.LanguageSelection.Response(
                result: ContentLanguageSwitch.ContentLanguageInfo(
                    availableContentLanguages: self.currentAvailableContentLanguages,
                    activeContentLanguage: selectedLanguage
                )
            )
        )
    }
}
