import Foundation

enum UserCourses {
    enum Tab: CaseIterable {
        case allCourses
        case favorites
        case archived

        var title: String {
            switch self {
            case .allCourses:
                return NSLocalizedString("UserCoursesTabAllCoursesTitle", comment: "")
            case .favorites:
                return NSLocalizedString("UserCoursesTabFavoritesTitle", comment: "")
            case .archived:
                return NSLocalizedString("UserCoursesTabArchivedTitle", comment: "")
            }
        }
    }

    // MARK: Use cases

    /// Show user courses course lists
    enum UserCoursesLoad {
        struct Request {}

        struct Response {}

        struct ViewModel {}
    }
}
