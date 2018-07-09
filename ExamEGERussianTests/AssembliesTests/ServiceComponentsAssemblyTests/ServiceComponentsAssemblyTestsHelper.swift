//
//  ServiceComponentsAssemblyTestsHelper.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 05/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class ServiceComponentsAssemblyTestsHelper {
    
    let serviceComponents: ServiceComponents
    
    init() {
        serviceComponents = ServiceComponentsAssembly(
            authAPI: AuthAPI(),
            stepicsAPI: StepicsAPI(),
            profilesAPI: ProfilesAPI(),
            defaultsStorageManager: DefaultsStorageManager(),
            randomCredentialsGenerator: RandomCredentialsGeneratorImplementation()
        )
    }
    
}
