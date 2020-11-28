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

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [AuthorsCourseListWidgetViewModel])
    }
}
