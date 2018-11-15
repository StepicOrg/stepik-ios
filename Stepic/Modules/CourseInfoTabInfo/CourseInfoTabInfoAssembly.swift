//
//  CourseInfoTabInfoAssembly.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class CourseInfoTabInfoAssembly: Assembly {
    // Input
    var moduleInput: CourseInfoTabInfoInputProtocol?

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabInfoProvider(
            usersAPI: UsersAPI()
        )
        let presenter = CourseInfoTabInfoPresenter()
        let interactor = CourseInfoTabInfoInteractor(
            presenter: presenter,
            provider: provider
        )
        self.moduleInput = interactor

        let viewController = CourseInfoTabInfoViewController(
            interactor: interactor
        )

        presenter.viewController = viewController

        return viewController
    }
}
