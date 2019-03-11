import Foundation

enum Home {
    // MARK: Submodules identifiers

    enum Submodule: String, UniqueIdentifiable {
        case streakActivity
        case continueCourse
        case enrolledCourses
        case popularCourses

        var uniqueIdentifier: UniqueIdentifierType {
            return self.rawValue
        }
    }

    // MARK: Use cases

    /// Content refresh (we should get language and authorization state)
    enum ContentLoad {
        struct Request { }

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
        struct Request { }

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

        struct Request { }

        struct Response {
            let module: Home.Submodule
            let result: State
        }

        struct ViewModel {
            let module: Home.Submodule
            let result: State
        }
    }
}
