import Foundation

enum BaseExplore {
    // MARK: Use cases

    /// Present fullscreen module
    enum FullscreenCourseListModulePresentation {
        struct Request {
            let presentationDescription: CourseList.PresentationDescription?
            let courseListType: CourseListType
        }

        struct Response {
            let presentationDescription: CourseList.PresentationDescription?
            let courseListType: CourseListType
        }

        struct ViewModel {
            let presentationDescription: CourseList.PresentationDescription?
            let courseListType: CourseListType
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
            let courseContinueSource: AnalyticsEvent.CourseContinueSource
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }

        struct ViewModel {
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let course: Course
            @available(*, deprecated, message: "Target modules can't be initialized w/o model")
            let isAdaptive: Bool
            let courseContinueSource: AnalyticsEvent.CourseContinueSource
            let courseViewSource: AnalyticsEvent.CourseViewSource
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

    enum AuthorizationPresentation {
        struct Response {}

        struct ViewModel {}
    }

    /// Present profile
    enum ProfilePresentation {
        struct Response {
            let userID: User.IdType
        }

        struct ViewModel {
            let userID: User.IdType
        }
    }

    /// Try to set online status for submodules
    enum TryToSetOnline {
        struct Request {
            let modules: [CourseListInputProtocol]
        }
    }
}
