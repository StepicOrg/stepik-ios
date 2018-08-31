//
//  CourseListPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseListAssembly: Assembly {
    // TODO: replace methods by properties
    private let type: CourseListType
    private var interactor: CourseListInteractor?

    init(type: CourseListType) {
        self.type = type
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
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            reviewSummariesNetworkService: CourseReviewSummariesNetworkService(courseReviewSummariesAPI: CourseReviewSummariesAPI())
        )
        self.interactor = CourseListInteractor(presenter: presenter, provider: provider)
        let controller = CourseListViewController(interactor: self.interactor!)

        presenter.viewController = controller
        return controller
    }

    func getModuleInput() -> CourseListInputProtocol {
        return self.interactor!
    }

    private func getPersistenceService() -> CourseListPersistenceServiceProtocol? {
        if let type = self.type as? PersistableCourseListTypeProtocol {
            return CourseListPersistenceService(type: type)
        } else {
            return nil
        }
    }
}
