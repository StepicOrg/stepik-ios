import UIKit

enum Explore {
    // MARK: Submodules identifiers

    enum Submodule: String, UniqueIdentifiable {
        case stories
        case languageSwitch
        case tags
        case collection
        case visitedCourses
        case popularCourses

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    // MARK: Use cases

    /// Content refresh
    enum ContentLoad {
        struct Request {}

        struct Response {
            let contentLanguage: ContentLanguage
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Check for language switch visibility
    enum LanguageSwitchAvailabilityCheck {
        struct Request {}

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

    // Refresh course block
    enum CourseListStateUpdate {
        enum State {
            case empty
            case error
        }

        struct Request {}

        struct Response {
            let module: Submodule
            let result: State
        }

        struct ViewModel {
            let module: Submodule
            let result: State
        }
    }

    /// Update status bar style (called by stories module)
    enum StatusBarStyleUpdate {
        struct Response {
            let statusBarStyle: UIStatusBarStyle
        }

        struct ViewModel {
            let statusBarStyle: UIStatusBarStyle
        }
    }

    /// Start search for courses
    enum SearchCourses {
        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case normal(contentLanguage: ContentLanguage)
    }
}
