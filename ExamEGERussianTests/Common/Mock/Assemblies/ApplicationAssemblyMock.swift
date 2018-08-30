//
//  ApplicationAssemblyMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class ApplicationAssemblyMock: ApplicationAssembly {
    func module() -> ApplicationModule {
        let router = AppRouter(
            tabBarController: UITabBarController(),
            navigationController: MockAssemblyNavigationController(),
            assemblyFactory: AssemblyFactoryMock()
        )

        return ApplicationModule(router: router)
    }
}
