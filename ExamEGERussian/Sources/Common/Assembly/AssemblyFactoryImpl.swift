//
//  AssemblyFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AssemblyFactoryImpl: AssemblyFactory {

    private let serviceFactory: ServiceFactory

    init(serviceFactory: ServiceFactory) {
        self.serviceFactory = serviceFactory
    }

    // MARK: - AssemblyFactory

    func authorizationAssembly() -> AuthorizationAssembly {
        return AuthorizationAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    func mainAssembly() -> MainAssembly {
        return MainAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

}
