import Foundation

enum StepFontSize: Int, CaseIterable, UniqueIdentifiable {
    case small
    case medium
    case large

    var uniqueIdentifier: UniqueIdentifierType { "\(self.rawValue)" }

    var title: String {
        switch self {
        case .small:
            return NSLocalizedString("SettingsStepFontSizeItemSmall", comment: "")
        case .medium:
            return NSLocalizedString("SettingsStepFontSizeItemMedium", comment: "")
        case .large:
            return NSLocalizedString("SettingsStepFontSizeItemLarge", comment: "")
        }
    }

    var h1: String {
        switch self {
        case .small:
            return "28"
        case .medium:
            return "33"
        case .large:
            return "36"
        }
    }

    var h2: String {
        switch self {
        case .small:
            return "22"
        case .medium:
            return "26"
        case .large:
            return "29"
        }
    }

    var h3: String {
        switch self {
        case .small:
            return "20"
        case .medium:
            return "24"
        case .large:
            return "26"
        }
    }

    var body: String {
        switch self {
        case .small:
            return "17"
        case .medium:
            return "20"
        case .large:
            return "22"
        }
    }

    var blockquote: String {
        switch self {
        case .small:
            return "17"
        case .medium:
            return "20"
        case .large:
            return "22"
        }
    }

    init?(uniqueIdentifier: UniqueIdentifierType) {
        if let value = Int(uniqueIdentifier),
           let fontSize = StepFontSize(rawValue: value) {
            self = fontSize
        } else {
            return nil
        }
    }
}
