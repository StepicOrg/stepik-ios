import Foundation

enum CourseInfo {
    enum Tab {
        case info
        case syllabus
        case reviews
        case news

        var title: String {
            switch self {
            case .info:
                return NSLocalizedString("CourseInfoTabInfo", comment: "")
            case .syllabus:
                return NSLocalizedString("CourseInfoTabSyllabus", comment: "")
            case .reviews:
                return NSLocalizedString("CourseInfoTabReviews", comment: "")
            case .news:
                return NSLocalizedString("CourseInfoTabNews", comment: "")
            }
        }
    }

    enum UserCourseAction {
        case favoriteAdd
        case favoriteRemove
        case archiveAdd
        case archiveRemove
    }

    enum CourseWishlistAction {
        case add
        case remove
    }

    // MARK: Use cases

    /// Load & show info about course
    enum CourseLoad {
        struct Request {}

        struct Response {
            struct Data {
                let course: Course
                let isWishlistAvailable: Bool
                let isCourseRevenueAvailable: Bool
                let promoCode: PromoCode?
            }

            var result: StepikResult<Data>
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
            let url: URL
            let courseViewSource: AnalyticsEvent.CourseViewSource
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

    /// Present course search module
    enum CourseContentSearchPresentation {
        struct Request {}

        struct Response {
            let courseID: Course.IdType
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    /// Add or remove course to/from withlist
    enum CourseWishlistMainAction {
        struct Request {}

        struct Response {
            let action: CourseWishlistAction
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

    /// Pop lesson module and do main course action
    enum LessonModuleBuyCourseActionPresentation {
        struct Response {}

        struct ViewModel {}
    }

    /// Pop lesson module and present catalog
    enum LessonModuleCatalogPresentation {
        struct Response {}

        struct ViewModel {}
    }

    /// Pop lesson module and present write review module
    enum LessonModuleWriteReviewPresentation {
        struct Response {}

        struct ViewModel {}
    }

    /// Do try for free action -> open preview lesson by id
    enum PreviewLessonPresentation {
        struct Request {}

        struct Response {
            let previewLessonID: Lesson.IdType
        }

        struct ViewModel {
            let previewLessonID: Lesson.IdType
        }
    }

    /// Present course revenue
    enum CourseRevenuePresentation {
        struct Request {}

        struct Response {
            let courseID: Course.IdType
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
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
            let courseViewSource: AnalyticsEvent.CourseViewSource
        }

        struct ViewModel {
            let urlPath: String
        }
    }

    /// Update remind purchase course notification
    enum PurchaseNotificationUpdate {
        struct Request {}
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
        case error
        case result(data: CourseInfoHeaderViewModel)
    }
}
