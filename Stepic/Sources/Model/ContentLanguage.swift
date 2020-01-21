import Foundation

enum ContentLanguage {
    case english
    case russian

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

    var searchCoursesParameter: String? {
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
