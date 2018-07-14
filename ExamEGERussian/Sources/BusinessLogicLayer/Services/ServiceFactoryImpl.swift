//
//  ServiceFactoryImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ServiceFactoryImpl: ServiceFactory {

    // MARK: - Private properties

    private let authAPI: AuthAPI
    private let stepicsAPI: StepicsAPI
    private let profilesAPI: ProfilesAPI

    // MARK: - Init

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, profilesAPI: ProfilesAPI) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
    }

    // MARK: - ServiceFactory

    func userRegistrationService() -> UserRegistrationService {
        return UserRegistrationServiceImpl(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            profilesAPI: profilesAPI,
            defaultsStorageManager: DefaultsStorageManager.shared,
            randomCredentialsGenerator: RandomCredentialsGeneratorImpl()
        )
    }

}
