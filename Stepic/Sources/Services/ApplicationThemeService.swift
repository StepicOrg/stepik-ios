import UIKit

protocol ApplicationThemeServiceProtocol: AnyObject {
    var theme: ApplicationTheme { get set }

    func registerDefaultTheme()
}

final class ApplicationThemeService: ApplicationThemeServiceProtocol {
    private static let applicationThemeKey = "applicationTheme"

    private let remoteConfig: RemoteConfig

    private var userSelectedApplicationTheme: ApplicationTheme? {
        if let stringValue = UserDefaults.standard.string(forKey: Self.applicationThemeKey) {
            return ApplicationTheme(rawValue: stringValue)
        }
        return nil
    }

    var theme: ApplicationTheme {
        get {
            if let userSelectedApplicationTheme = self.userSelectedApplicationTheme {
                return userSelectedApplicationTheme
            } else {
                return self.remoteConfig.isDarkModeAvailable ? .default : .light
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
                return self.applyTheme(.light)
            }

            if let userSelectedApplicationTheme = self.userSelectedApplicationTheme {
                self.applyTheme(userSelectedApplicationTheme)
            } else {
                self.applyTheme(.default)
            }
        }
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
