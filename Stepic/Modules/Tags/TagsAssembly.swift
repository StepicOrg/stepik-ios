//
//  TagsTagsAssembly.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class TagsAssembly: Assembly {
    let contentLanguage: ContentLanguage

    init(contentLanguage: ContentLanguage) {
        self.contentLanguage = contentLanguage
    }

    func makeModule() -> UIViewController {
        let provider = TagsProvider()
        let presenter = TagsPresenter()
        let interactor = TagsInteractor(
            presenter: presenter,
            provider: provider,
            contentLanguage: self.contentLanguage
        )
        let viewController = TagsViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
