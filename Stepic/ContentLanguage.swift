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

    static let supportedLanguages: [ContentLanguage] = [.russian, .english]

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

    var fullString: String {
        switch self {
        case .russian:
            return "Русский"
        case .english:
            return "English"
        }
    }

    var popularCoursesParameter: String? {
        switch self {
        case .russian:
            // both - english & russian
            return nil
        case .english:
            return "en"
        }
    }

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
}
