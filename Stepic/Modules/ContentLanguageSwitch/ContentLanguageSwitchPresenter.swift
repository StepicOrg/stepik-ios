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
}

final class ContentLanguageSwitchPresenter: ContentLanguageSwitchPresenterProtocol {
    weak var viewController: ContentLanguageSwitchViewControllerProtocol?

    func presentLanguages(response: ContentLanguageSwitch.ShowLanguages.Response) {
        var viewModels: [ContentLanguageSwitchViewModel] = []
        for language in response.result.availableContentLanguages {
            let viewModel = ContentLanguageSwitchViewModel(
                title: language.displayingString,
                isSelected: language == response.result.activeContentLanguage
            )
            viewModels.append(viewModel)
        }

        let viewModel = ContentLanguageSwitch.ShowLanguages.ViewModel(
            state: ContentLanguageSwitch.ViewControllerState.result(data: viewModels)
        )
        viewController?.displayLanguages(viewModel: viewModel)
    }
}
