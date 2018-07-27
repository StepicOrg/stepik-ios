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

    // MARK: - ServiceFactory -

    func userRegistrationService(for type: UserRegistrationServiceType) -> UserRegistrationService {
        let credentialsProvider: UserRegistrationServiceCredentialsProvider
        switch type {
        case .real(let provider):
            credentialsProvider = provider
        case .fake:
            credentialsProvider = RandomCredentialsProvider()
        }

        return UserRegistrationServiceImpl(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            profilesAPI: profilesAPI,
            defaultsStorageManager: DefaultsStorageManager.shared,
            credentialsProvider: credentialsProvider
        )
    }

    var graphService: GraphService {
        return GraphServiceImpl()
    }

    // MARK: - Init

    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
    }
}
