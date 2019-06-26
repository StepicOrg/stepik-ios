import Foundation

protocol ContentLanguageServiceProtocol: class {
    var globalContentLanguage: ContentLanguage { get set }
}

final class ContentLanguageService: ContentLanguageServiceProtocol {
    private static let sharedContentLanguageKey = "contentLanguage"

    // TODO: Replace with cache driver
    var globalContentLanguage: ContentLanguage {
        set {
            let oldValue = self.globalContentLanguage
            self.setInDefaults(newLanguage: newValue)
            if newValue != oldValue {
                NotificationCenter.default.post(
                    name: .contentLanguageDidChange,
                    object: ["newContentLanguage": newValue]
                )
            }
        }
        get {
            guard let cachedValue = UserDefaults.standard.value(
                forKey: ContentLanguageService.sharedContentLanguageKey
            ) as? String else {
                self.setInDefaults(newLanguage: self.appInterfaceLanguage)
                return self.appInterfaceLanguage
            }

            return ContentLanguage(languageString: cachedValue)
        }
    }

    private var appInterfaceLanguage: ContentLanguage {
        let currentLanguageString = Bundle.main.preferredLocalizations.first ?? "en"
        return ContentLanguage(languageString: currentLanguageString)
    }

    private func setInDefaults(newLanguage: ContentLanguage) {
        UserDefaults.standard.setValue(
            newLanguage.languageString,
            forKey: ContentLanguageService.sharedContentLanguageKey
        )
    }
}

extension Foundation.Notification.Name {
    static let contentLanguageDidChange = Foundation.Notification.Name("contentLanguageDidChange")
}
