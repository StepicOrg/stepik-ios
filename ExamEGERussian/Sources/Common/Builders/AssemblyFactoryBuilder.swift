//
//  AssemblyFactoryBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AssemblyFactoryBuilder {
    private var serviceFactory: ServiceFactory?

    func setServiceFactory(_ serviceFactory: ServiceFactory) -> AssemblyFactoryBuilder {
        self.serviceFactory = serviceFactory
        return self
    }

    func build() -> AssemblyFactory {
        guard let serviceFactory = serviceFactory else {
            fatalError("`serviceFactory` is nil. Call `setServiceFactory(_:)` before.")
        }

        return AssemblyFactoryImpl(
            serviceFactory: serviceFactory,
            knowledgeGraph: KnowledgeGraph()
        )
    }
}
