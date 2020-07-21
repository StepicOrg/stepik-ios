import Foundation

enum NewProfileCreatedCourses {
    /// Show courses
    enum CoursesLoad {
        struct Request {}

        struct Response {
            let teacherID: User.IdType
        }

        struct ViewModel {
            let teacherID: User.IdType
        }
    }

    /// Try to set online status
    enum OnlineModeReset {
        struct Request {
            let module: CourseListInputProtocol
        }
    }

    /// Present course syllabus
    enum CourseSyllabusPresentation {
        struct Response {
            let course: Course
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }

        struct ViewModel {
            let courseID: Course.IdType
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }
    }

    /// Present course info
    enum CourseInfoPresentation {
        struct Response {
            let course: Course
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }

        struct ViewModel {
            let courseID: Course.IdType
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }
    }

    /// Present last step in course
    enum LastStepPresentation {
        struct Response {
            let course: Course
            let isAdaptive: Bool
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }

        struct ViewModel {
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let course: Course
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let isAdaptive: Bool
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }
    }

    /// Present authorization
    enum PresentAuthorization {
        struct Response {}

        struct ViewModel {}
    }

    /// Present error
    enum PresentError {
        struct Response {}

        struct ViewModel {}
    }
}
