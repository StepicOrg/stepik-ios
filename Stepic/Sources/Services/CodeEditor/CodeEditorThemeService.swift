import UIKit

protocol CodeEditorThemeServiceProtocol: AnyObject {
    var theme: CodeEditorTheme { get }

    func update(name: String)
}

// FIXME: Migrate to StorageManager
final class CodeEditorThemeService: CodeEditorThemeServiceProtocol {
    private static let defaultDarkModeThemeName: String = "vs2015"

    private let applicationThemeService: ApplicationThemeServiceProtocol

    init(
        applicationThemeService: ApplicationThemeServiceProtocol = ApplicationThemeService()
    ) {
        self.applicationThemeService = applicationThemeService
    }

    var theme: CodeEditorTheme {
        CodeEditorTheme(font: self.font, name: self.themeName)
    }

    private var font: UIFont {
        let codeElementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
        let fontSize = codeElementsSize.elements.editor.realSizes.fontSize
        return UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    private var themeName: String {
        get {
            if case .dark = self.currentApplicationTheme {
                return self.darkModeThemeName
            } else {
                return self.lightModeThemeName
            }
        }
        set {
            if case .dark = self.currentApplicationTheme {
                self.darkModeThemeName = newValue
            } else {
                self.lightModeThemeName = newValue
            }
        }
    }

    // TODO: Remove PreferencesContainer.
    private var lightModeThemeName: String {
        get {
            PreferencesContainer.codeEditor.theme
        }
        set {
            PreferencesContainer.codeEditor.theme = newValue
        }
    }

    private var darkModeThemeName: String {
        get {
            if let themeName = UserDefaults.standard.string(forKey: Key.themeNameDarkMode.rawValue) {
                return themeName
            } else {
                self.darkModeThemeName = Self.defaultDarkModeThemeName
                return Self.defaultDarkModeThemeName
            }
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.themeNameDarkMode.rawValue)
        }
    }

    var currentApplicationTheme: ApplicationTheme {
        switch self.applicationThemeService.theme {
        case .system:
            if #available(iOS 13.0, *) {
                switch UITraitCollection.current.userInterfaceStyle {
                case .dark:
                    return .dark
                default:
                    return .light
                }
            } else {
                return .light
            }
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }

    func update(name: String) {
        self.themeName = name
    }

    enum Key: String {
        case themeNameDarkMode = "themeKeyDarkMode"
    }
}
