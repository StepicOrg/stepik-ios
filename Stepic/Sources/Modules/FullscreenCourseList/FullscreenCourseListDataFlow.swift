import Foundation

enum FullscreenCourseList {
    // MARK: Use cases

    /// Present course syllabus
    enum CourseSyllabusPresentation {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    /// Present course info
    enum CourseInfoPresentation {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    /// Present last step in course
    enum LastStepPresentation {
        struct Response {
            let course: Course
            let isAdaptive: Bool
        }

        struct ViewModel {
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let course: Course
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let isAdaptive: Bool
        }
    }

    /// Present web view for paid course
    enum PaidCourseBuyingPresentation {
        struct Response {
            let course: Course
        }

        struct ViewModel {
            let urlPath: String
        }
    }

    /// Try to set online status
    enum OnlineModeReset {
        struct Request {
            let module: CourseListInputProtocol
        }
    }

    enum PresentAuthorization {
        struct Response { }

        struct ViewModel { }
    }

    enum PresentPlaceholder {
        enum PlaceholderState {
            case error
            case empty
        }

        struct Response {
            let state: PlaceholderState
        }

        struct ViewModel {
            let state: PlaceholderState
        }
    }
}
