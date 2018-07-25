//
//  AssemblyFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AssemblyFactoryImpl: AssemblyFactory {
    var applicationAssembly: ApplicationAssembly {
        return ApplicationAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var authorizationAssembly: AuthorizationAssembly {
        return AuthorizationAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var mainAssembly: MainAssembly {
        return MainAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var topicsAssembly: TopicsAssembly {
        return TopicsAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    private let serviceFactory: ServiceFactory

    init(serviceFactory: ServiceFactory) {
        self.serviceFactory = serviceFactory
    }
}
