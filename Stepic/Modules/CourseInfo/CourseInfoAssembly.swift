//
//  CourseInfoCourseInfoAssembly.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 30/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class CourseInfoAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = CourseInfoProvider()
        let presenter = CourseInfoPresenter()
        let interactor = CourseInfoInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseInfoViewController()
        presenter.viewController = viewController
        return viewController
    }
}
