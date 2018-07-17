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

    let authAPI: AuthAPI
    let stepicsAPI: StepicsAPI
    let profilesAPI: ProfilesAPI
    let notificationStatusesAPI: NotificationStatusesAPI

    // MARK: - Init

    init(authAPI: AuthAPI, stepicsAPI: StepicsAPI, profilesAPI: ProfilesAPI,
         notificationStatusesAPI: NotificationStatusesAPI) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
        self.notificationStatusesAPI = notificationStatusesAPI
    }

    // MARK: - ServiceFactory

    func userRegistrationService() -> UserRegistrationService {
        return FakeUserRegistrationService(
            authAPI: authAPI,
            stepicsAPI: stepicsAPI,
            profilesAPI: profilesAPI,
            defaultsStorageManager: DefaultsStorageManager.shared,
            randomCredentialsGenerator: RandomCredentialsGeneratorImpl()
        )
    }

}
