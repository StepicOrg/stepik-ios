enum CourseList {
    // MARK: Common structs

    struct ListData<T> {
        var courses: [T]
        var hasNextPage: Bool
    }

    // We should pass not only courses
    // but also info about which of them can be opened in adaptive mode
    struct AvailableCourses {
        var fetchedCourses: ListData<(UniqueIdentifierType, Course)>
        var availableAdaptiveCourses: Set<Course>
    }

    // Use it for module initializing
    struct PresentationDescription {
        var title: String
        var subtitle: String?
        var color: GradientCoursesPlaceholderView.Color
    }

    // MARK: Use cases

    /// Load and show courses for given course list
    enum CoursesLoad {
        struct Request { }

        struct Response {
            let isAuthorized: Bool
            let result: AvailableCourses
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }
    /// Load and show next course page for given course list
    enum NextCoursesLoad {
        struct Request { }

        struct Response {
            let isAuthorized: Bool
            let result: AvailableCourses
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Click on primary button
    enum PrimaryCourseAction {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Click on secondary button
    enum SecondaryCourseAction {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Click on course
    enum MainCourseAction {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: ListData<CourseWidgetViewModel>)
    }

    enum PaginationState {
        case result(data: ListData<CourseWidgetViewModel>)
        case error(message: String)
    }
}
