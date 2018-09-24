//
//  FullscreenCourseListFullscreenCourseListAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class FullscreenCourseListAssembly: Assembly {
    let presentationDescription: FullscreenCourseListViewController.PresentationDescription?
    let courseListType: CourseListType

    init(
        presentationDescription: FullscreenCourseListViewController.PresentationDescription? = nil,
        courseListType: CourseListType
    ) {
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType
    }

    func makeModule() -> UIViewController {
        let provider = FullscreenCourseListProvider()
        let presenter = FullscreenCourseListPresenter()
        let interactor = FullscreenCourseListInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = FullscreenCourseListViewController(
            interactor: interactor,
            courseListType: self.courseListType
        )

        presenter.viewController = viewController
        return viewController
    }
}
