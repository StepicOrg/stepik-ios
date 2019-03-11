//
//  ExploreExploreAssembly.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

class ExploreAssembly: Assembly {
    func makeModule() -> UIViewController {
        let presenter = ExplorePresenter()
        let interactor = ExploreInteractor(
            presenter: presenter,
            contentLanguageService: ContentLanguageService(),
            networkReachabilityService: NetworkReachabilityService(),
            languageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityService()
        )
        let viewController = ExploreViewController(
            interactor: interactor
        )

        presenter.viewController = viewController
        return viewController
    }
}
