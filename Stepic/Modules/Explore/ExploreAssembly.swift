//
//  ExploreExploreAssembly.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class ExploreAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = ExploreProvider()
        let presenter = ExplorePresenter()
        let interactor = ExploreInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = ExploreViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
