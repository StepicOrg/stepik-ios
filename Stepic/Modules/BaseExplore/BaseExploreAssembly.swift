//
//  BaseExploreBaseExploreAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 02/10/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class BaseExploreAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = BaseExplorePresenter()
        let interactor = BaseExploreInteractor(
            presenter: presenter,
            contentLanguageService: ContentLanguageService()
        )
        let viewController = BaseExploreViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
