//
//  AmplitudeAnalyticsEvents.swift
//  Stepic
//
//  Created by Ostrenkiy on 19.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct AmplitudeAnalyticsEvents {
    struct Launch {
        static let firstTime = "Launch first time"
        static let sessionStart = "Session start"
    }

    struct Onboarding {
        static let screenOpened = "Onboarding screen opened"
        static let closed = "Onboarding closed"
        static let passed = "Onboarding passed"
    }

    struct SignIn {
        static let loggedIn = "Logged in"
    }

    struct SignUp {
        static let registered = "Registered"
    }

    struct Course {
        static let joined = "Course joined"
        static let continuePressed = "Continue course pressed"
    }

    struct Steps {
        static let submissionMade = "Submission made"
        static let stepOpened = "Step opened"
    }

    struct Downloads {
        static let started = "Download started"
        static let cancelled = "Download cancelled"
    }

    struct Search {
        static let searched = "Course searched"
    }
}
