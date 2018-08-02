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

    var authAssembly: AuthAssembly {
        return AuthAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    var topicsAssembly: TopicsAssembly {
        return TopicsAssemblyImpl(
            assemblyFactory: self,
            serviceFactory: serviceFactory,
            knowledgeGraph: knowledgeGraph
        )
    }

    var lessonsAssembly: LessonsAssembly {
        return LessonsAssemblyImpl(
            assemblyFactory: self,
            serviceFactory: serviceFactory,
            knowledgeGraph: knowledgeGraph
        )
    }

    var stepsAssembly: StepsAssembly {
        return StepsAssemblyImpl(assemblyFactory: self, serviceFactory: serviceFactory)
    }

    private let serviceFactory: ServiceFactory
    private let knowledgeGraph: KnowledgeGraph

    init(serviceFactory: ServiceFactory, knowledgeGraph: KnowledgeGraph) {
        self.serviceFactory = serviceFactory
        self.knowledgeGraph = knowledgeGraph
    }
}
