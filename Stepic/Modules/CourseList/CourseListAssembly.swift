//
//  CourseListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseListAssembly: Assembly {
    private let type: CourseListType
    private let colorMode: CourseListColorMode

    // Input
    var moduleInput: CourseListInputProtocol?

    // Output
    private var moduleOutput: CourseListOutputProtocol?

    init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        output: CourseListOutputProtocol? = nil
    ) {
        self.type = type
        self.colorMode = colorMode
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let presenter = CourseListPresenter()
        let provider = CourseListProvider(
            type: self.type,
            networkService: CourseListNetworkService(
                type: self.type,
                coursesAPI: CoursesAPI()
            ),
            persistenceService: self.getPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(
                progressesAPI: ProgressesAPI()
            ),
            reviewSummariesNetworkService: CourseReviewSummariesNetworkService(
                courseReviewSummariesAPI: CourseReviewSummariesAPI()
            )
        )

        let interactor = CourseListInteractor(
            presenter: presenter,
            provider: provider,
            adaptiveStorageManager: AdaptiveStorageManager()
        )
        self.moduleInput = interactor

        let controller = CourseListViewController(
            interactor: interactor,
            colorMode: self.colorMode
        )
        controller.moduleOutput = self.moduleOutput

        presenter.viewController = controller
        return controller
    }

    private func getPersistenceService() -> CourseListPersistenceServiceProtocol? {
        if let type = self.type as? PersistableCourseListTypeProtocol {
            return CourseListPersistenceService(type: type)
        } else {
            return nil
        }
    }
}
