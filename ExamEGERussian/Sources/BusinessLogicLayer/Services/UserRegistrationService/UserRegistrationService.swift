//
//  UserRegistrationService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: UserRegistrationServiceError: Error

enum UserRegistrationServiceError: Error {
    case notRegistered
    case notLoggedIn
    case noProfileFound
    case notUnregisteredFromEmails
}

// MARK: - UserRegistrationService -

protocol UserRegistrationService {

    var defaultsStorageManager: DefaultsStorageManager { get }

    var authAPI: AuthAPI { get }

    var stepicsAPI: StepicsAPI { get }

    var randomCredentialsGenerator: RandomCredentialsGenerator { get }

    func registerNewUser() -> Promise<User>

    func registerUser() -> Promise<(email: String, password: String)>

    func logInUser(email: String, password: String) -> Promise<User>

    func unregisterFromEmail(user: User) -> Promise<User>

}
