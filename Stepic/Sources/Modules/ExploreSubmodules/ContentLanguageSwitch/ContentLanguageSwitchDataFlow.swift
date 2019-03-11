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
        let availableContentLanguages: [(UniqueIdentifierType, ContentLanguage)]
        let activeContentLanguage: ContentLanguage
    }

    // MARK: Use cases

    /// Show languages
    enum LanguagesLoad {
        struct Request { }

        struct Response {
            let result: ContentLanguageInfo
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Change languages
    enum LanguageSelection {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let result: ContentLanguageInfo
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [ContentLanguageSwitchViewModel])
        case error(message: String)
    }
}
