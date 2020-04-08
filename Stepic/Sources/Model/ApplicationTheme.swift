import Foundation

enum ApplicationTheme: String, CaseIterable, UniqueIdentifiable {
    case system
    case dark
    case light

    var uniqueIdentifier: UniqueIdentifierType { self.rawValue }

    var title: String {
        switch self {
        case .system:
            return NSLocalizedString("SettingsThemeItemSystem", comment: "")
        case .dark:
            return NSLocalizedString("SettingsThemeItemDark", comment: "")
        case .light:
            return NSLocalizedString("SettingsThemeItemLight", comment: "")
        }
    }

    init?(uniqueIdentifier: UniqueIdentifierType) {
        if let applicationTheme = ApplicationTheme(rawValue: uniqueIdentifier) {
            self = applicationTheme
        } else {
            return nil
        }
    }
}
