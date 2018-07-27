//
//  ServiceFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceFactoryImpl: ServiceFactory {
    let authAPI: AuthAPI
    let stepicsAPI: StepicsAPI
    let profilesAPI: ProfilesAPI

    var userRegistrationService: UserRegistrationService {
        return UserRegistrationServiceImpl(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            profilesAPI: profilesAPI,
            defaultsStorageManager: DefaultsStorageManager.shared
        )
    }

    var graphService: GraphService {
        return GraphServiceImpl()
    }

    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
    }
}
