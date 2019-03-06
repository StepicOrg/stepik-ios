//
//  FullscreenCourseListFullscreenCourseListAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class FullscreenCourseListAssembly: Assembly {
    let presentationDescription: CourseList.PresentationDescription?
    let courseListType: CourseListType

    init(
        presentationDescription: CourseList.PresentationDescription? = nil,
        courseListType: CourseListType
    ) {
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType
    }

    func makeModule() -> UIViewController {
        let presenter = FullscreenCourseListPresenter()
        let interactor = FullscreenCourseListInteractor(
            presenter: presenter,
            networkReachabilityService: NetworkReachabilityService()
        )
        let viewController = FullscreenCourseListViewController(
            interactor: interactor,
            courseListType: self.courseListType,
            presentationDescription: self.presentationDescription
        )

        presenter.viewController = viewController
        return viewController
    }
}
