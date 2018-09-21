//
//  ContentLanguageSwitchContentLanguageSwitchPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContentLanguageSwitchPresenterProtocol {
    func presentLanguages(response: ContentLanguageSwitch.ShowLanguages.Response)
    func presentLanguageChange(response: ContentLanguageSwitch.SelectLanguage.Response)
}

final class ContentLanguageSwitchPresenter: ContentLanguageSwitchPresenterProtocol {
    weak var viewController: ContentLanguageSwitchViewControllerProtocol?

    func presentLanguages(response: ContentLanguageSwitch.ShowLanguages.Response) {
        var viewModels: [ContentLanguageSwitchViewModel] = []
        for (index, language) in response.result.availableContentLanguages.enumerated() {
            let viewModel = ContentLanguageSwitchViewModel(
                title: language.displayingString,
                isSelected: language == response.result.activeContentLanguage,
                uniqueIdentifier: "\(index)"
            )
            viewModels.append(viewModel)
        }

        let viewModel = ContentLanguageSwitch.ShowLanguages.ViewModel(
            state: ContentLanguageSwitch.ViewControllerState.result(data: viewModels)
        )
        viewController?.displayLanguages(viewModel: viewModel)
    }

    func presentLanguageChange(response: ContentLanguageSwitch.SelectLanguage.Response) {
        var viewModels: [ContentLanguageSwitchViewModel] = []
        for (index, language) in response.result.availableContentLanguages.enumerated() {
            let viewModel = ContentLanguageSwitchViewModel(
                title: language.displayingString,
                isSelected: language == response.result.activeContentLanguage,
                uniqueIdentifier: "\(index)"
            )
            viewModels.append(viewModel)
        }

        let viewModel = ContentLanguageSwitch.SelectLanguage.ViewModel(
            state: ContentLanguageSwitch.ViewControllerState.result(data: viewModels)
        )
        viewController?.displayLanguageChange(viewModel: viewModel)
    }
}
