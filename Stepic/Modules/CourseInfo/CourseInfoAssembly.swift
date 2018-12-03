//
//  CourseInfoCourseInfoAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class CourseInfoAssembly: Assembly {
    private var courseID: Course.IdType

    init(courseID: Course.IdType) {
        self.courseID = courseID
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoProvider()
        let presenter = CourseInfoPresenter()
        let interactor = CourseInfoInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseInfoViewController(
            interactor: interactor
        )
        presenter.viewController = viewController
        return viewController
    }
}
