//
//  MainViewRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class MainViewRouterImpl: BaseRouter, MainViewRouter {
    func showAuthorizationModule() {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authorizationAssembly().greeting().module()
        })
    }
}
