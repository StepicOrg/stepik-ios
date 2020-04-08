import UIKit

protocol ApplicationThemeServiceProtocol: AnyObject {
    var theme: ApplicationTheme { get set }

    func registerDefaultTheme()
}

final class ApplicationThemeService: ApplicationThemeServiceProtocol {
    private static let applicationThemeKey = "applicationTheme"

    private let remoteConfig: RemoteConfig

    var theme: ApplicationTheme {
        get {
            if let applicationTheme = self.getApplicationTheme() {
                return applicationTheme
            } else {
                return .default
            }
        }
        set {
            if #available(iOS 13.0, *) {
                self.applyTheme(newValue)
                UserDefaults.standard.set(newValue.rawValue, forKey: Self.applicationThemeKey)
            }
        }
    }

    init(remoteConfig: RemoteConfig = .shared) {
        self.remoteConfig = remoteConfig
    }

    func registerDefaultTheme() {
        if #available(iOS 13.0, *) {
            guard self.remoteConfig.isDarkModeAvailable else {
                self.theme = .light
                return
            }

            if let userSelectedApplicationTheme = self.getApplicationTheme() {
                self.applyTheme(userSelectedApplicationTheme)
            } else {
                self.theme = .default
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
        DispatchQueue.main.async {
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.overrideUserInterfaceStyle = theme.userInterfaceStyle
            }
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
