//
//  CourseInfoTabReviewsAssembly.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

final class CourseInfoTabReviewsAssembly: Assembly {
    // Input
    var moduleInput: CourseInfoTabReviewsInputProtocol?

    func makeModule() -> UIViewController {
        let presenter = CourseInfoTabReviewsPresenter()
        let provider = CourseInfoTabReviewsProvider(
            courseReviewsPersistenceService: CourseReviewsPersistenceService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(courseReviewsAPI: CourseReviewsAPI())
        )
        let interactor = CourseInfoTabReviewsInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseInfoTabReviewsViewController(interactor: interactor)

        presenter.viewController = viewController
        self.moduleInput = interactor

        return viewController
    }
}
