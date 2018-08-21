//
//  StepsAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 21/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class StepsAssembly: BaseAssembly, StepsAssemblyProtocol {
    var standart: StandartStepsAssemblyProtocol {
        return StandartStepsAssembly(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }

    var adaptive: AdaptiveStepsAssemblyProtocol {
        return AdaptiveStepsAssembly(assemblyFactory: assemblyFactory, serviceFactory: serviceFactory)
    }
}
