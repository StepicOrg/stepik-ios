//
//  BaseAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class BaseAssembly {
    let assemblyFactory: AssemblyFactory
    let serviceFactory: ServiceFactory

    init(assemblyFactory: AssemblyFactory, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        self.serviceFactory = serviceFactory
    }
}
