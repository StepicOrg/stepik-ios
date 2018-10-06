//
//  HomeHomeDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum Home {
    // MARK: Submodules identifiers

    enum Submodule: String, UniqueIdentifiable {
        case streakActivity
        case continueCourse
        case enrolledCourses
        case popularCourses

        var uniqueIdentifier: UniqueIdentifierType {
            return self.rawValue
        }
    }

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
        enum State {
            case empty
            case error
            case anonymous
            case normal
        }

        struct Request { }

        struct Response {
            let result: State
        }

        struct ViewModel {
            let result: State
        }
    }
    // Show popular courses
    enum LoadPopularCourses {
        enum State {
            case empty
            case error
            case normal
        }

        struct Request { }

        struct Response {
            let result: State
        }

        struct ViewModel {
            let result: State
        }
    }
}
