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

    // Properties that enable us to set exactly what User or error
    // we want our mocked UserRegistrationService to return for request.
    var user: User?
    var error: Error?

    func registerNewUser() -> Promise<User> {
        return logInUser(email: "email", password: "password")
    }

    func logInUser(email: String, password: String) -> Promise<User> {
        return Promise { seal in
            seal.resolve(user, error)
        }
    }

}
