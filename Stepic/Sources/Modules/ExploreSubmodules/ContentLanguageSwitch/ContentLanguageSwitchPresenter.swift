//
//  ContentLanguageSwitchContentLanguageSwitchPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

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
        viewController?.displayLanguages(viewModel: viewModel)
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
        viewController?.displayLanguageChange(viewModel: viewModel)
    }
}
