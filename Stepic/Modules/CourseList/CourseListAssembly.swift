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
    private let orientation: CourseListViewController.PresentationOrientation

    // Input
    var moduleInput: CourseListInputProtocol?

    // Output
    private weak var moduleOutput: CourseListOutputProtocol?

    init(
        type: CourseListType,
        colorMode: CourseListColorMode,
        presentationOrientation: CourseListViewController.PresentationOrientation,
        output: CourseListOutputProtocol? = nil
    ) {
        self.type = type
        self.colorMode = colorMode
        self.orientation = presentationOrientation
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let servicesFactory = CourseListServicesFactory(
            type: self.type,
            coursesAPI: CoursesAPI(),
            userCoursesAPI: UserCoursesAPI()
        )

        let presenter = CourseListPresenter()
        let provider = CourseListProvider(
            type: self.type,
            networkService: servicesFactory.makeNetworkService(),
            persistenceService: servicesFactory.makePersistenceService(),
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
            adaptiveStorageManager: AdaptiveStorageManager(),
            courseSubscriber: CourseSubscriber()
        )
        self.moduleInput = interactor

        let controller = CourseListViewController(
            interactor: interactor,
            colorMode: self.colorMode,
            orientation: self.orientation
        )

        presenter.viewController = controller
        interactor.moduleOutput = self.moduleOutput
        return controller
    }
}
