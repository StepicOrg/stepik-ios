//
//  ContinueCourseContinueCourseAssembly.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

final class ContinueCourseAssembly: Assembly {
    func makeModule() -> UIViewController {
        let provider = ContinueCourseProvider()
        let presenter = ContinueCoursePresenter()
        let interactor = ContinueCourseInteractor(
            presenter: presenter, 
            provider: provider
        )
        let viewController = ContinueCourseViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
