//
//  ExploreExploreDataFlow.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum Explore {
    // MARK: Use cases

    /// Content refresh
    enum LoadContent {
        struct Request { }

        struct Response {
            let contentLanguage: ContentLanguage
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }
    /// Check for language switch visibility
    enum CheckLanguageSwitchAvailability {
        struct Request { }

        struct Response {
            let isHidden: Bool
        }

        struct ViewModel {
            let isHidden: Bool
        }
    }
    /// Present fullscreen module
    enum PresentFullscreenCourseListModule {
        struct Request {
            let courseListType: CourseListType
        }

        struct Response {
            let courseListType: CourseListType
        }

        struct ViewModel {
            let courseListType: CourseListType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case normal(contentLanguage: ContentLanguage)
    }
}
