//
//  StepsAssemblyProtocol.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 21/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol StepsAssemblyProtocol: class {
    var standart: StandartStepsAssemblyProtocol { get }
    var adaptive: AdaptiveStepsAssemblyProtocol { get }
}
