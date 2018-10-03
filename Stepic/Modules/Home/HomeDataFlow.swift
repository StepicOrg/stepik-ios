//
//  HomeHomeDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum Home {
    // MARK: Use cases

    /// Show streak activity
    enum LoadStreak {
        struct Request { }

        struct Response {
            enum Result {
                case hidden
                case success(currentStreak: Int, needsToSolveToday: Bool)
            }

            let result: Result
        }

        struct ViewModel {
            enum Result {
                case hidden
                case visible(message: String, streak: Int)
            }

            let result: Result
        }
    }
    // Show enrolled courses
    enum LoadEnrolledCourses {
        struct Request { }

        struct Response {
            let isAuthorized: Bool
        }

        struct ViewModel {
            let isAuthorized: Bool
        }
    }
}
