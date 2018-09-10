//
//  AssemblyFactory.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/// The AssemblyFactory protocol returns assemblies of each module of the presentation layer.
protocol AssemblyFactory: class {
    var applicationAssembly: ApplicationAssembly { get }
    var authAssembly: AuthAssembly { get }
    var topicsAssembly: TopicsAssembly { get }
    var lessonsAssembly: LessonsAssemblyProtocol { get }
    var stepsAssembly: StepsAssemblyProtocol { get }
}
