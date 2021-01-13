import Foundation

// swiftlint:disable nesting

enum Home {
    // MARK: Submodules identifiers

    enum Submodule: String, UniqueIdentifiable {
        case stories
        case streakActivity
        case continueCourse
        case enrolledCourses
        case visitedCourses
        case popularCourses

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    // MARK: Use cases

    /// Content refresh (we should get language and authorization state)
    enum ContentLoad {
        struct Request {}

        struct Response {
            let isAuthorized: Bool
            let contentLanguage: ContentLanguage
        }

        struct ViewModel {
            let isAuthorized: Bool
            let contentLanguage: ContentLanguage
        }
    }

    /// Show streak activity
    enum StreakLoad {
        struct Request {}

        struct Response {
            enum Result {
                case hidden
                case success(currentStreak: Int, needsToSolveToday: Bool)
            }

            let result: Result
        }

        struct ViewModel {
            enum Result {
                case hidden
                case visible(message: String, streak: Int)
            }

            let result: Result
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
            let module: Home.Submodule
            let result: State
        }

        struct ViewModel {
            let module: Home.Submodule
            let result: State
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

    /// Update status bar style (called by stories module)
    enum StatusBarStyleUpdate {
        struct Response {
            let statusBarStyle: UIStatusBarStyle
        }

        struct ViewModel {
            let statusBarStyle: UIStatusBarStyle
        }
    }
}
