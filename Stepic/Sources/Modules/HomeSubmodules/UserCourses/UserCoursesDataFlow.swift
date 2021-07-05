import Foundation

enum UserCourses {
    enum Tab: String, CaseIterable {
        case allCourses = "all"
        case favorites
        case downloaded
        case archived = "archive"

        var title: String {
            switch self {
            case .allCourses:
                return NSLocalizedString("UserCoursesTabAllCoursesTitle", comment: "")
            case .favorites:
                return NSLocalizedString("UserCoursesTabFavoritesTitle", comment: "")
            case .downloaded:
                return NSLocalizedString("UserCoursesTabDownloadedTitle", comment: "")
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
