//
//  ContentLanguageSwitchContentLanguageSwitchInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol ContentLanguageSwitchInteractorProtocol {
    func showLanguages(request: ContentLanguageSwitch.ShowLanguages.Request)
}

final class ContentLanguageSwitchInteractor: ContentLanguageSwitchInteractorProtocol {
    let presenter: ContentLanguageSwitchPresenterProtocol
    let provider: ContentLanguageSwitchProviderProtocol

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
            self.presenter.presentLanguages(
                response: ContentLanguageSwitch.ShowLanguages.Response(
                    result: ContentLanguageSwitch.ContentLanguageInfo(
                        availableContentLanguages: availableContentLanguages,
                        activeContentLanguage: currentContentLanguage
                    )
                )
            )
        }.catch { _ in
            fatalError("Unexpected error while extracting info about languages")
        }
    }
}
