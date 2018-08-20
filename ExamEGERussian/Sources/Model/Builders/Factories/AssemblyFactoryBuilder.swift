//
//  AssemblyFactoryBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AssemblyFactoryBuilder {
    private let serviceFactory: ServiceFactory

    init(serviceFactory: ServiceFactory) {
        self.serviceFactory = serviceFactory
    }

    func build() -> AssemblyFactory {
        return AssemblyFactoryImpl(
            serviceFactory: serviceFactory,
            knowledgeGraphProvider: CacheKnowledgeGraphProvider(graphService: serviceFactory.graphService)
        )
    }
}
