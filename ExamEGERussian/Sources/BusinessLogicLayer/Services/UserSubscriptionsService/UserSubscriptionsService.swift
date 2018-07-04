//
//  UserSubscriptionsService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: UserSubscriptionsServiceError: Error

enum UserSubscriptionsServiceError: Error {
    case noProfile
    case userNotUnregisteredFromEmails
}

// MARK: - UserSubscriptionsService -

protocol UserSubscriptionsService {
    
    var profilesAPI: ProfilesAPI { get }
    
    func unregisterFromEmail(user: User) -> Promise<User>
    
}
