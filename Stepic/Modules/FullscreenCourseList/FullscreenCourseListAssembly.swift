//
//  FullscreenCourseListFullscreenCourseListAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class FullscreenCourseListAssembly: Assembly {
    let presentationDescription: FullscreenCourseListViewController.PresentationDescription

    init(presentationDescription: FullscreenCourseListViewController.PresentationDescription) {
        self.presentationDescription = presentationDescription
    }

    func makeModule() -> UIViewController {
        let provider = FullscreenCourseListProvider()
        let presenter = FullscreenCourseListPresenter()
        let interactor = FullscreenCourseListInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = FullscreenCourseListViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
