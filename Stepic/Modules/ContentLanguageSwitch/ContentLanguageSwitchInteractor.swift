//
//  ContentLanguageSwitchContentLanguageSwitchInterac?tor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ContentLanguageSwitchInteractorProtocol {
    func showLanguages(request: ContentLanguageSwitch.ShowLanguages.Request)
    func selectLanguage(request: ContentLanguageSwitch.SelectLanguage.Request)
}

final class ContentLanguageSwitchInteractor: ContentLanguageSwitchInteractorProtocol {
    let presenter: ContentLanguageSwitchPresenterProtocol
    let provider: ContentLanguageSwitchProviderProtocol

    private var currentAvailableContentLanguages: [(UniqueIdentifierType, ContentLanguage)] = []

    init(
        presenter: ContentLanguageSwitchPresenterProtocol,
        provider: ContentLanguageSwitchProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func showLanguages(request: ContentLanguageSwitch.ShowLanguages.Request) {
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
                response: ContentLanguageSwitch.ShowLanguages.Response(
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

    func selectLanguage(request: ContentLanguageSwitch.SelectLanguage.Request) {
        guard let selectedLanguage = self.currentAvailableContentLanguages
            .first(where: { $0.0 == request.viewModelUniqueIdentifier })?.1 else {
            fatalError("Request contains invalid data")
        }

        self.presenter.presentLanguageChange(
            response: ContentLanguageSwitch.SelectLanguage.Response(
                result: ContentLanguageSwitch.ContentLanguageInfo(
                    availableContentLanguages: self.currentAvailableContentLanguages,
                    activeContentLanguage: selectedLanguage
                )
            )
        )
    }
}
