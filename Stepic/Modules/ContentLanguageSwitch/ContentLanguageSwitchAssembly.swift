//
//  ContentLanguageSwitchContentLanguageSwitchAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class ContentLanguageSwitchAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = ContentLanguageSwitchProvider(
            contentLanguageService: ContentLanguageService()
        )
        let presenter = ContentLanguageSwitchPresenter()
        let interactor = ContentLanguageSwitchInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = ContentLanguageSwitchViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
