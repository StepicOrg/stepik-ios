import Foundation

enum Explore {
    // MARK: Submodules identifiers

    enum Submodule: String, UniqueIdentifiable {
        case stories
        case languageSwitch
        case tags
        case collection
        case popularCourses

        var uniqueIdentifier: UniqueIdentifierType {
            return self.rawValue
        }
    }

    // MARK: Use cases

    /// Content refresh
    enum ContentLoad {
        struct Request {
        }

        struct Response {
            let contentLanguage: ContentLanguage
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Check for language switch visibility
    enum LanguageSwitchAvailabilityCheck {
        struct Request { }

        struct Response {
            let isHidden: Bool
        }

        struct ViewModel {
            let isHidden: Bool
        }
    }

    /// Update stories visibility
    enum StoriesVisibilityUpdate {
        @available(*, deprecated, message: "Should be refactored with VIP cycle as CheckLanguageSwitchAvailability")
        struct Response {
            let isHidden: Bool
        }

        @available(*, deprecated, message: "Should be refactored with VIP cycle as CheckLanguageSwitchAvailability")
        struct ViewModel {
            let isHidden: Bool
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case normal(contentLanguage: ContentLanguage)
    }
}
