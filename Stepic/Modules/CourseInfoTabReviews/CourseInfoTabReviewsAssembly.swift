//
//  CourseInfoTabReviewsAssembly.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

final class CourseInfoTabReviewsAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = CourseInfoTabReviewsPresenter()
        let interactor = CourseInfoTabReviewsInteractor(presenter: presenter)
        let viewController = CourseInfoTabReviewsViewController(interactor: interactor)
        presenter.viewController = viewController

        return viewController
    }
}
