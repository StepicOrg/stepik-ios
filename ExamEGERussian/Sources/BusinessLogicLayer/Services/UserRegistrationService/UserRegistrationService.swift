//
//  UserRegistrationService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

enum UserRegistrationServiceError: Error {
    case notRegistered
    case notLoggedIn
    case noProfileFound
    case notUnregisteredFromEmails
}

enum UserRegistrationServiceType {
    case fake
    case real(UserRegistrationServiceCredentialsProvider)
}

protocol UserRegistrationServiceCredentialsProvider {
    var firstname: String { get }
    var lastname: String { get }
    var email: String { get }
    var password: String { get }
}

protocol UserRegistrationService {
    var credentialsProvider: UserRegistrationServiceCredentialsProvider { get }

    func registerNewUser() -> Promise<User>
    func registerUser() -> Promise<(email: String, password: String)>
    func logInUser(email: String, password: String) -> Promise<User>
    func unregisterFromEmail(user: User) -> Promise<User>
}
