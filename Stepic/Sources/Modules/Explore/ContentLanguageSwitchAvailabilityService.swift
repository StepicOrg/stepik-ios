import Foundation

protocol ContentLanguageSwitchAvailabilityServiceProtocol: class {
    var shouldShowLanguageSwitchOnExplore: Bool { get set }
}

final class ContentLanguageSwitchAvailabilityService: ContentLanguageSwitchAvailabilityServiceProtocol {
    private static let shouldDisplayContentLanguageWidgetKey = "shouldDisplayContentLanguageWidget"

    var shouldShowLanguageSwitchOnExplore: Bool {
        get {
            return UserDefaults.standard.value(
                forKey: ContentLanguageSwitchAvailabilityService
                    .shouldDisplayContentLanguageWidgetKey
            ) as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: ContentLanguageSwitchAvailabilityService
                    .shouldDisplayContentLanguageWidgetKey
            )
        }
    }
}
