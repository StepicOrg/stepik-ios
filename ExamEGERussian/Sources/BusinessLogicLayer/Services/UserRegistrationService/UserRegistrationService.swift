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
}

// MARK: - UserRegistrationService -

protocol UserRegistrationService {
    
    var defaultsStorageManager: DefaultsStorageManager { get }
    
    var authAPI: AuthAPI { get }
    
    var stepicsAPI: StepicsAPI { get }
    
    func registerNewUser() -> Promise<User>
    
    func logInUser(email: String, password: String) -> Promise<User>
    
}
