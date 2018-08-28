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
            persistenceService: nil
        )
        let interactor = CourseListInteractor(presenter: presenter, provider: provider)
        let controller = CourseListViewController(interactor: interactor)

        presenter.viewController = controller
        return controller
    }
}
