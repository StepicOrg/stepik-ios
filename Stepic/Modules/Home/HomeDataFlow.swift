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

    /// Content refresh (we should get language and authorization state)
    enum LoadContent {
        struct Request { }

        struct Response {
            let isAuthorized: Bool
            let contentLanguage: ContentLanguage
        }

        struct ViewModel {
            let isAuthorized: Bool
            let contentLanguage: ContentLanguage
        }
    }
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
    // Refresh course block
    enum RefreshCourseList {
        enum State {
            case empty
            case error
            case normal
        }

        struct Request { }

        struct Response {
            let module: Home.Submodule
            let result: State
        }

        struct ViewModel {
            let module: Home.Submodule
            let result: State
        }
    }
}
