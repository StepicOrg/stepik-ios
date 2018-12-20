//
//  ActiveSplitTestsListAssembly.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class ActiveSplitTestsListAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = ActiveSplitTestsListProvider()
        let presenter = ActiveSplitTestsListPresenter()
        let interactor = ActiveSplitTestsListInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = ActiveSplitTestsListViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
