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
        let availableContentLanguagesGuarantee = self.provider.fetchAvailableLanguages()
        let currentContentLanguageGuarantee = self.provider.fetchCurrentLanguage()

        when(
            availableContentLanguagesGuarantee.asVoid(),
            currentContentLanguageGuarantee.asVoid()
        ).done {
            guard let availableContentLanguages = availableContentLanguagesGuarantee.value,
                  let currentContentLanguage = currentContentLanguageGuarantee.value else {
                return
            }

            let languages = availableContentLanguages.map { language -> (UniqueIdentifierType, ContentLanguage) in
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
        }
    }

    func doLanguageSelection(request: ContentLanguageSwitch.LanguageSelection.Request) {
        guard let selectedLanguage = self.currentAvailableContentLanguages.first(
            where: { $0.0 == request.viewModelUniqueIdentifier }
        )?.1 else {
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
