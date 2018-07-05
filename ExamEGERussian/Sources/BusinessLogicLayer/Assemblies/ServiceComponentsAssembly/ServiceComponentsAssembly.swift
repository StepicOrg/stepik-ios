//
//  ServiceComponentsAssembly.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceComponentsAssembly: ServiceComponents {
    
    let userRegistrationService: UserRegistrationService
    
    let userSubscriptionsService: UserSubscriptionsService
    
    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI,
         defaultsStorageManager: DefaultsStorageManager
        ) {
        self.userSubscriptionsService = UserSubscriptionsServiceImplementation(
            profilesAPI: profilesAPI
        )
        self.userRegistrationService = UserRegistrationServiceImplementation(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            userSubscriptionsService: userSubscriptionsService,
            defaultsStorageManager: defaultsStorageManager
        )
    }
    
}
