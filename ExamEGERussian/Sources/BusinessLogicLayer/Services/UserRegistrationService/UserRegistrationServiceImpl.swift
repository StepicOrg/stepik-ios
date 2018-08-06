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
    private let authAPI: AuthAPI
    private let stepicsAPI: StepicsAPI
    private let profilesAPI: ProfilesAPI
    private let defaultsStorageManager: DefaultsStorageManager

    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         profilesAPI: ProfilesAPI,
         defaultsStorageManager: DefaultsStorageManager) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.profilesAPI = profilesAPI
        self.defaultsStorageManager = defaultsStorageManager
    }

    func register(with params: UserRegistrationParams) -> Promise<(email: String, password: String)> {
        if let savedEmail = defaultsStorageManager.accountEmail,
           let savedPassword = defaultsStorageManager.accountPassword,
           savedEmail == params.email && savedPassword == params.password {
            return .value((email: savedEmail, password: savedPassword))
        }

        return Promise { seal in
            self.authAPI.signUpWithAccount(
                firstname: params.firstname,
                lastname: params.lastname,
                email: params.email,
                password: params.password
            ).done {
                seal.fulfill((email: params.email, password: params.password))
            }.catch { error in
                print("\(#file): failed to register new user with error: \(error)")
                seal.reject(UserRegistrationServiceError.notRegistered)
            }
        }
    }

    func signIn(email: String, password: String) -> Promise<User> {
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
                print("\(#file): failed to login user with error: \(error)")
                seal.reject(UserRegistrationServiceError.notLoggedIn)
            }
        }
    }

    func registerAndSignIn(with params: UserRegistrationParams) -> Promise<User> {
        return Promise { seal in
            checkToken().then {
                self.register(with: params)
            }.then { email, password in
                self.signIn(email: email, password: password)
            }.done { user in
                seal.fulfill(user)
            }.catch { error in
                seal.reject(error)
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
                    print("\(#file): profile not found")
                    return Promise(error: UserRegistrationServiceError.noProfileFound)
                }
            }.done { _ in
                seal.fulfill(user)
            }.catch { error in
                print("\(#file): failed to unregister user from email with error: \(error)")
                seal.reject(UserRegistrationServiceError.notUnregisteredFromEmails)
            }
        }
    }

}
