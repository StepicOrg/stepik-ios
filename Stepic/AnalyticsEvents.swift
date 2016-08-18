//
//  AnalyticsEvents.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

struct AnalyticsEvents {
    
    struct Logout {
        static let clicked = "clicked logout"
        static let accepted = "accepted logout"
    }
        
    struct SignIn {
        static let onLaunchScreen = "clicked SignIn on launch screen"
        static let onSignInScreen = "clicked SignIn on sign in screen"
    }
    
    struct SignUp {
        static let onLaunchScreen = "clicked SignUp on launch screen"
        static let onSignUpScreen = "clicked SignUp on sign up screen"
    }
    
    struct Syllabus {
        static let shared = "share syllabus clicked"
    }
    
    struct Section {
        static let cache = "clicked cache section"
        static let cancel = "clicked cancel section"
        static let delete = "clicked delete cached section"
    }
    
    struct Unit {
        static let cache = "clicked cache unit"
        static let cancel = "clicked cancel unit"
        static let delete = "clicked delete cached unit"
    }
    
    struct Downloads {
        static let clear = "clicked clear cache"
        static let accepted = "clicked accepted clear cache"
    }
    
    struct CourseOverview {
        static let shared = "share course clicked"
    }
    
    struct Step {        
        struct Video {
            static let rateChanged = "video rate changed"
            static let qualityChanged = "video quality changed"
        }
        
        struct Submission {
            static let submit = "clicked submit"
            static let newAttempt = "clicked generate new attempt"
        }
    }
    
    struct Discussion {
        static let liked = "discussion liked"
        static let abused = "discussion abused"
    }
    
}