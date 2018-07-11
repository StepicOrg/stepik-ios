//
//  UserRegistrationServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 06/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class UserRegistrationServiceMock: UserRegistrationService {

    let authAPI = AuthAPI()

    let stepicsAPI = StepicsAPI()

    let defaultsStorageManager = DefaultsStorageManager()

    var randomCredentialsGenerator: RandomCredentialsGenerator {
        return RandomCredentialsGeneratorImplementation()
    }

    // Properties that enable us to set exactly what User or error
    // we want our mocked UserRegistrationService to return for request.
    var user: User?
    var error: Error?

    func registerNewUser() -> Promise<User> {
        return logInUser(email: "email", password: "password")
    }

    func registerUser() -> Promise<(email: String, password: String)> {
        let credentials = (randomCredentialsGenerator.email, randomCredentialsGenerator.password)
        return Promise { seal in
            seal.resolve(credentials, error)
        }
    }

    func logInUser(email: String, password: String) -> Promise<User> {
        return Promise { seal in
            seal.resolve(user, error)
        }
    }

    func unregisterFromEmail(user: User) -> Promise<User> {
        return .value(user)
    }

}
