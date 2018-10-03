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
    /// Update stories visibility
    enum UpdateStoriesVisibility {
        @available(*, deprecated, message: "Should be refactored with VIP cycle as CheckLanguageSwitchAvailability")
        struct Response {
            let isHidden: Bool
        }

        @available(*, deprecated, message: "Should be refactored with VIP cycle as CheckLanguageSwitchAvailability")
        struct ViewModel {
            let isHidden: Bool
        }
    }
}
