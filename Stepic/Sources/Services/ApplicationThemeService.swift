import UIKit

protocol ApplicationThemeServiceProtocol: AnyObject {
    var theme: ApplicationTheme { get set }

    func registerDefaultTheme()
}

final class ApplicationThemeService: ApplicationThemeServiceProtocol {
    private static let applicationThemeKey = "applicationTheme"
    private static let defaultApplicationTheme = ApplicationTheme.system

    var theme: ApplicationTheme {
        get {
            if let applicationTheme = self.getApplicationTheme() {
                return applicationTheme
            } else {
                return Self.defaultApplicationTheme
            }
        }
        set {
            if #available(iOS 13.0, *) {
                self.applyTheme(newValue)
                UserDefaults.standard.set(newValue.rawValue, forKey: Self.applicationThemeKey)
            }
        }
    }

    func registerDefaultTheme() {
        if #available(iOS 13.0, *) {
            if let userSelectedApplicationTheme = self.getApplicationTheme() {
                self.applyTheme(userSelectedApplicationTheme)
            } else {
                self.theme = Self.defaultApplicationTheme
            }
        }
    }

    private func getApplicationTheme() -> ApplicationTheme? {
        if let stringValue = UserDefaults.standard.string(forKey: Self.applicationThemeKey) {
            return ApplicationTheme(rawValue: stringValue)
        }
        return nil
    }

    @available(iOS 13.0, *)
    private func applyTheme(_ theme: ApplicationTheme) {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.overrideUserInterfaceStyle = theme.userInterfaceStyle
        }
    }
}

@available(iOS 13.0, *)
private extension ApplicationTheme {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system:
            return .unspecified
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
}
