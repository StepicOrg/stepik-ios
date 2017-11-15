//
//  ContentLanguage.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum ContentLanguage {
    case english, russian

    init(languageString: String) {
        switch languageString {
        case "ru":
            self = .russian
        case "en":
            self = .english
        default:
            self = .english
        }
    }

    var languageString: String {
        switch self {
        case .russian:
            return "ru"
        case .english:
            return "en"
        }
    }

    var displayingString: String {
        switch self {
        case .russian:
            return "Ru"
        case .english:
            return "En"
        }
    }

    private static var appInterfaceLanguage: ContentLanguage {
        let currentLanguageString = Bundle.main.preferredLocalizations.first ?? "en"
        return ContentLanguage(languageString: currentLanguageString)
    }

    private static let sharedContentLanguageKey = "contentLanguage"
    static var sharedContentLanguage: ContentLanguage {
        set(value) {
            UserDefaults.standard.setValue(value.languageString, forKey: sharedContentLanguageKey)
        }
        get {
            if let cachedValue = UserDefaults.standard.value(forKey: sharedContentLanguageKey) as? String {
                return ContentLanguage(languageString: cachedValue)
            } else {
                self.sharedContentLanguage = appInterfaceLanguage
                return appInterfaceLanguage
            }
        }
    }
}
