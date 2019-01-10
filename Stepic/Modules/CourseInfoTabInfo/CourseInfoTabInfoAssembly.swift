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

    // Output
    private weak var moduleOutput: CourseInfoTabInfoOutputProtocol?

    init(output: CourseInfoTabInfoOutputProtocol? = nil) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = CourseInfoTabInfoProvider(
            usersNetworkService: UsersNetworkService(usersAPI: UsersAPI())
        )
        let presenter = CourseInfoTabInfoPresenter()
        let interactor = CourseInfoTabInfoInteractor(
            presenter: presenter,
            provider: provider
        )
        let viewController = CourseInfoTabInfoViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput
        self.moduleInput = interactor

        return viewController
    }
}
