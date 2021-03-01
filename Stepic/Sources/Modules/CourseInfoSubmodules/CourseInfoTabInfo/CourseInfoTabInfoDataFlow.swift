import Foundation

enum CourseInfoTabInfo {
    // MARK: Use cases

    enum InfoLoad {
        struct Request {}

        struct Response {
            let course: Course?
            let streamVideoQuality: StreamVideoQuality
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    enum ControllerAppearance {
        struct Response {}

        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoTabInfoViewModel)
    }
}
