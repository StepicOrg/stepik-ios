//
//  UserRegistrationServiceImplementation.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class UserRegistrationServiceImpl: UserRegistrationService {

    // MARK: - Private Properties

    private let authAPI: AuthAPI
    private let stepicsAPI: StepicsAPI
    private let profilesAPI: ProfilesAPI
    private let defaultsStorageManager: DefaultsStorageManager
    private let randomCredentialsGenerator: RandomCredentialsGenerator

    // MARK: - Init

    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI,
         defaultsStorageManager: DefaultsStorageManager,
         randomCredentialsGenerator: RandomCredentialsGenerator) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
        self.defaultsStorageManager = defaultsStorageManager
        self.randomCredentialsGenerator = randomCredentialsGenerator
    }

    // MARK: - UserRegistrationService

    func registerNewUser() -> Promise<User> {
        return Promise { seal in
            checkToken().then {
                self.registerUser()
            }.then { email, password -> Promise<User> in
                self.logInUser(email: email, password: password)
            }.then { user in
                self.unregisterFromEmail(user: user)
            }.done { user in
                seal.fulfill(user)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func logInUser(email: String, password: String) -> Promise<User> {
        defaultsStorageManager.accountEmail = email
        defaultsStorageManager.accountPassword = password

        return Promise { seal in
            self.authAPI.signInWithAccount(
                email: email,
                password: password
            ).then { token, authorizationType -> Promise<User> in
                AuthInfo.shared.token = token
                AuthInfo.shared.authorizationType = authorizationType

                return self.stepicsAPI.retrieveCurrentUser()
            }.done { user in
                AuthInfo.shared.user = user
                User.removeAllExcept(user)

                seal.fulfill(user)
            }.catch { error in
                print("ExamEgeRussian: failed to login user with error: \(error)")
                seal.reject(UserRegistrationServiceError.notLoggedIn)
            }
        }
    }

    func registerUser() -> Promise<(email: String, password: String)> {
        if let savedEmail = defaultsStorageManager.accountEmail,
            let savedPassword = defaultsStorageManager.accountPassword {
            return .value((email: savedEmail, password: savedPassword))
        }

        let email = randomCredentialsGenerator.email
        let password = randomCredentialsGenerator.password

        return Promise { seal in
            self.authAPI.signUpWithAccount(
                firstname: randomCredentialsGenerator.firstname,
                lastname: randomCredentialsGenerator.lastname,
                email: email,
                password: password
            ).done {
                seal.fulfill((email: email, password: password))
            }.catch { error in
                print("UserRegistrationService: failed to register new user with error: \(error)")
                seal.reject(UserRegistrationServiceError.notRegistered)
            }
        }
    }

    func unregisterFromEmail(user: User) -> Promise<User> {
        return Promise { seal in
            self.profilesAPI.retrieve(
                ids: [user.profile],
                existing: []
            ).then { profiles -> Promise<Profile> in
                if let profile = profiles.first {
                    profile.subscribedForMail = false
                    return self.profilesAPI.update(profile)
                } else {
                    print("UserRegistrationService: profile not found")
                    return Promise(error: UserRegistrationServiceError.noProfileFound)
                }
            }.done { _ in
                seal.fulfill(user)
            }.catch { error in
                print("UserRegistrationService: failed to unregister user from email with error: \(error)")
                seal.reject(UserRegistrationServiceError.notUnregisteredFromEmails)
            }
        }
    }

}
