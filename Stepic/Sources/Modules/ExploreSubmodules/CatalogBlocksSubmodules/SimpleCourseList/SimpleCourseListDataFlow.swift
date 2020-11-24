import Foundation

enum SimpleCourseList {
    // MARK: Use Cases

    /// Show catalog block
    enum CourseListLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<[SimpleCourseListsCatalogBlockContentItem]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [SimpleCourseListWidgetViewModel])
    }
}
