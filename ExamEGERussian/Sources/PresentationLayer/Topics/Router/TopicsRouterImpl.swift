//
//  TopicsRouterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 26/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsRouterImpl: BaseRouter, TopicsRouter {
    func showAuth() {
        presentModalNavigationController(derivedFrom: { _ in
            assemblyFactory.authorizationAssembly.greeting.module()
        })
    }
}
