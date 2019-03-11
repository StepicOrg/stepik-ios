import Foundation

enum CourseInfoTabInfo {
    // MARK: Use cases

    enum InfoLoad {
        struct Request { }

        struct Response {
            let course: Course?
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoTabInfoViewModel)
    }
}
