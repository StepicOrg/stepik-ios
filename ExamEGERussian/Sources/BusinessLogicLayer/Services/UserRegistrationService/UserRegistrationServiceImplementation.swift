//
//  UserRegistrationServiceImplementation.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class UserRegistrationServiceImplementation: UserRegistrationService {
    
    let userSubscriptionsService: UserSubscriptionsService
    
    // MARK: Initializers
    
    init(authAPI: AuthAPI,
         stepicsAPI: StepicsAPI,
         userSubscriptionsService: UserSubscriptionsService,
         defaultsStorageManager: DefaultsStorageManager
        ) {
        self.authAPI = authAPI
        self.stepicsAPI = stepicsAPI
        self.userSubscriptionsService = userSubscriptionsService
        self.defaultsStorageManager = defaultsStorageManager
    }
    
    // MARK: - UserRegistrationService
    
    let defaultsStorageManager: DefaultsStorageManager
    
    let authAPI: AuthAPI
    
    let stepicsAPI: StepicsAPI
    
    func registerNewUser() -> Promise<User> {
        return Promise { fulfill, reject in
            checkToken().then {
                self.registerUser()
            }.then { email, password -> Promise<User> in
                self.logInUser(email: email, password: password)
            }.then { user in
                self.userSubscriptionsService.unregisterFromEmail(user: user)
            }.then { user -> Void in
                fulfill(user)
            }.catch { error in
                reject(error)
            }
        }
    }
    
    func logInUser(email: String, password: String) -> Promise<User> {
        defaultsStorageManager.accountEmail = email
        defaultsStorageManager.accountPassword = password
        
        return Promise { fulfill, reject in
            self.authAPI.signInWithAccount(
                email: email,
                password: password
            ).then { token, authorizationType -> Promise<User> in
                AuthInfo.shared.token = token
                AuthInfo.shared.authorizationType = authorizationType
                
                return self.stepicsAPI.retrieveCurrentUser()
            }.then { user -> Void in
                AuthInfo.shared.user = user
                User.removeAllExcept(user)
                
                fulfill(user)
            }.catch { error in
                print("ExamEgeRussian: failed to login user with error: \(error)")
                reject(UserRegistrationServiceError.userNotLoggedIn)
            }
        }
    }
    
    // MARK: Private API
    
    private func registerUser() -> Promise<(email: String, password: String)> {
        if let savedEmail = defaultsStorageManager.accountEmail,
            let savedPassword = defaultsStorageManager.accountPassword {
            return Promise(value: (email: savedEmail, password: savedPassword))
        }
        
        let firstname = StringHelper.generateRandomString(of: 6)
        let lastname = StringHelper.generateRandomString(of: 6)
        let email = "exam_ege_russian_ios_\(Int(Date().timeIntervalSince1970))\(StringHelper.generateRandomString(of: 5))@stepik.org"
        let password = StringHelper.generateRandomString(of: 16)
        
        return Promise { fulfill, reject in
            self.authAPI.signUpWithAccount(
                firstname: firstname,
                lastname: lastname,
                email: email,
                password: password
            ).then { _ -> Void in
                fulfill((email: email, password: password))
            }.catch { error in
                print("ExamEgeRussian: failed to register new user with error: \(error)")
                reject(UserRegistrationServiceError.userNotRegistered)
            }
        }
    }
    
}
