//
//  ContentLanguageSwitchContentLanguageSwitchDataFlow.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation

enum ContentLanguageSwitch {
    // MARK: Common structs
    struct ContentLanguageInfo {
        var availableContentLanguages: [ContentLanguage]
        var activeContentLanguage: ContentLanguage
    }

    // MARK: Use cases

    /// Show languages
    enum ShowLanguages {
        struct Request { }

        struct Response {
            var result: ContentLanguageInfo
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [ContentLanguageSwitchViewModel])
        case error(message: String)
    }
}
