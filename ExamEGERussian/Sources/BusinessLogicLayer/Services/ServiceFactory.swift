//
//  ServiceFactory.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ServiceFactory: class {
    var authAPI: AuthAPI { get }
    var stepicsAPI: StepicsAPI { get }
    var profilesAPI: ProfilesAPI { get }
    var notificationStatusesAPI: NotificationStatusesAPI { get }

    func userRegistrationService(for type: UserRegistrationServiceType) -> UserRegistrationService
    var graphService: GraphService { get }
}

extension ServiceFactory {
    var fakeUserRegistrationService: UserRegistrationService {
        return userRegistrationService(for: .fake)
    }
}
