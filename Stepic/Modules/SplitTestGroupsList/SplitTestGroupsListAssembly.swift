//
//  SplitTestGroupsListSplitTestGroupsListAssembly.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class SplitTestGroupsListAssembly: Assembly {
    private let splitTestUniqueIdentifier: UniqueIdentifierType

    init(splitTestUniqueIdentifier: UniqueIdentifierType) {
        self.splitTestUniqueIdentifier = splitTestUniqueIdentifier
    }

    func makeModule() -> UIViewController {
        let provider = SplitTestGroupsListProvider(storage: UserDefaults.standard)
        let presenter = SplitTestGroupsListPresenter()
        let interactor = SplitTestGroupsListInteractor(
            presenter: presenter,
            provider: provider,
            splitTestUniqueIdentifier: self.splitTestUniqueIdentifier
        )
        let viewController = SplitTestGroupsListViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
