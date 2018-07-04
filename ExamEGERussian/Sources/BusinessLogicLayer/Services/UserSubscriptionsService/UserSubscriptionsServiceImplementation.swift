//
//  UserSubscriptionsServiceImplementation.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 04/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class UserSubscriptionsServiceImplementation: UserSubscriptionsService {
    
    init(profilesAPI: ProfilesAPI) {
        self.profilesAPI = profilesAPI
    }
    
    // MARK: UserSubscriptionsService
    
    let profilesAPI: ProfilesAPI
    
    func unregisterFromEmail(user: User) -> Promise<User> {
        return Promise { fulfill, reject in
            self.profilesAPI.retrieve(
                ids: [user.profile],
                existing: []
            ).then { profiles -> Promise<Profile> in
                if let profile = profiles.first {
                    profile.subscribedForMail = false
                    return self.profilesAPI.update(profile)
                } else {
                    print("ExamEGERussian: profile not found")
                    
                    return Promise(error: UserSubscriptionsServiceError.noProfile)
                }
            }.then { _ -> Void in
                fulfill(user)
            }.catch { error in
                print("ExamEGERussian: failed to unregister user from email with error: \(error)")
                
                reject(UserSubscriptionsServiceError.userNotUnregisteredFromEmails)
            }
        }
    }
    
}
