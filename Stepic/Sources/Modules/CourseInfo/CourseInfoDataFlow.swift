import Foundation

enum CourseInfo {
    enum Tab {
        case info
        case syllabus
        case reviews

        var title: String {
            switch self {
            case .info:
                return NSLocalizedString("CourseInfoTabInfo", comment: "")
            case .syllabus:
                return NSLocalizedString("CourseInfoTabSyllabus", comment: "")
            case .reviews:
                return NSLocalizedString("CourseInfoTabReviews", comment: "")
            }
        }
    }

    enum UserCourseAction {
        case favoriteAdd
        case favoriteRemove
        case archiveAdd
        case archiveRemove
    }

    // MARK: Use cases

    /// Load & show info about course
    enum CourseLoad {
        struct Request {}

        struct Response {
            struct Data {
                let course: Course
                let iapLocalizedPrice: String?
            }

            var result: Swift.Result<Data, Swift.Error>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Register submodules
    enum SubmoduleRegistration {
        struct Request {
            var submodules: [Int: CourseInfoSubmoduleProtocol]
        }
    }

    /// Show lesson
    enum LessonPresentation {
        struct Response {
            let unitID: Unit.IdType
        }

        struct ViewModel {
            let unitID: Unit.IdType
        }
    }

    /// Show personal deadlines create / edit & delete action
    enum PersonalDeadlinesSettingsPresentation {
        enum Action {
            case create
            case edit
        }

        struct Response {
            let action: Action

            @available(*, deprecated, message: "Should containts only course ID")
            let course: Course
        }

        struct ViewModel {
            let action: Action

            @available(*, deprecated, message: "Should containts only course ID")
            let course: Course
        }
    }

    /// Present exam in web
    enum ExamLessonPresentation {
        struct Response {
            let urlPath: String
        }

        struct ViewModel {
            let urlPath: String
        }
    }

    /// Share course
    enum CourseShareAction {
        struct Request {}

        struct Response {
            let urlPath: String
        }

        struct ViewModel {
            let urlPath: String
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

    /// Handle submodule controller appearance
    enum SubmoduleAppearanceUpdate {
        struct Request {
            let submoduleIndex: Int
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

    /// Drop course
    enum CourseUnenrollmentAction {
        struct Request {}
    }

    /// Add/remove course to/from favorites
    enum CourseFavoriteAction {
        struct Request {}
    }

    /// Move/remove course to/from archived
    enum CourseArchiveAction {
        struct Request {}
    }

    /// Present HUD with status and localized message
    enum UserCourseActionPresentation {
        struct Response {
            let userCourseAction: UserCourseAction
            let isSuccessful: Bool
        }

        struct ViewModel {
            let isSuccessful: Bool
            let message: String
        }
    }

    /// Do main action (continue, enroll, etc)
    enum MainCourseAction {
        struct Request {}
    }

    /// Try to set online mode
    enum OnlineModeReset {
        struct Request {}
    }

    /// Register for remote notifications
    enum RemoteNotificationsRegistration {
        struct Request {}
    }

    /// Present authorization controller
    enum AuthorizationPresentation {
        struct Response {}

        struct ViewModel {}
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

    /// Present in-app purchases are not allowed alert
    enum IAPNotAllowedPresentation {
        struct Response {
            let error: Error
            let course: Course
        }

        struct ViewModel {
            let title: String
            let message: String
            let urlPath: String
        }
    }

    /// Present in-app purchases receipt validation error alert
    enum IAPReceiptValidationFailedPresentation {
        struct Response {
            let error: Error
            let course: Course
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    /// Retry validate receipt
    enum IAPReceiptValidationRetry {
        struct Request {}
    }

    /// Present in-app purchases payment failed alert
    enum IAPPaymentFailedPresentation {
        struct Response {
            let error: Error
            let course: Course
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: CourseInfoHeaderViewModel)
    }
}
