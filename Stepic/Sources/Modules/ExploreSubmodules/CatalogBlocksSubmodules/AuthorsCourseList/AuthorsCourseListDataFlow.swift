import Foundation

enum AuthorsCourseList {
    // MARK: Use Cases

    /// Show catalog block
    enum CourseListLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<[AuthorsCatalogBlockContentItem]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Present author profile
    enum AuthorPresentation {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [AuthorsCourseListWidgetViewModel])
    }
}
