//
//  ContentLanguageContentLanguageAssembly.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class ContentLanguageAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = ContentLanguageProvider()
        let presenter = ContentLanguagePresenter()
        let interactor = ContentLanguageInteractor(
            presenter: presenter, 
            provider: provider
        )
        let viewController = ContentLanguageViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
