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

struct UserRegistrationParams {
    let firstname: String
    let lastname: String
    let email: String
    let password: String
}

protocol UserRegistrationService {
    /// Register new user.
    ///
    /// - Parameter params: User registration parameters contains of:
    ///   - firstname
    ///   - lastname
    ///   - email
    ///   - password
    /// - Returns: Promise object with tuple of email and password.
    func register(with params: UserRegistrationParams) -> Promise<(email: String, password: String)>
    /// Signs user into account.
    ///
    /// - Parameters:
    ///   - email: User email address.
    ///   - password: User account password.
    /// - Returns: Signed in user account.
    func signIn(email: String, password: String) -> Promise<User>
    /// Unregister user from email list notifications.
    ///
    /// - Parameter user: User to remove from email notifications.
    /// - Returns: Updated User object.
    func unregisterFromEmail(user: User) -> Promise<User>
    /// Sequentially performs registration and sign in actions.
    ///
    /// - Parameter params: User registration parameters contains of:
    ///   - firstname
    ///   - lastname
    ///   - email
    ///   - password
    /// - Returns: Returns Promise object with newly registered User object.
    func registerAndSignIn(with params: UserRegistrationParams) -> Promise<User>
}
