//
//  SubmissonManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class SubmissionManager {
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate let didMakeSuccessfulSubmissionKey = "didMakeSuccessfulSubmissionKey"
    
    var didMakeSuccessfulSubmission: Bool {
        get {
            if let didMake = defaults.value(forKey: didMakeSuccessfulSubmissionKey) as? Bool {
                return didMake
            } else {
                self.didMakeSuccessfulSubmission = false
                return false 
            }
        }
        
        set(value) {
            defaults.set(value, forKey: didMakeSuccessfulSubmissionKey)
            defaults.synchronize()
        }
    }

}
