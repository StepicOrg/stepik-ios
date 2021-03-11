import Foundation

enum Submissions {
    // MARK: Use Cases

    /// Show submissions list
    enum SubmissionsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<SubmissionsData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part/page of the submissions
    enum NextSubmissionsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<SubmissionsData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Show submission module
    enum SubmissionPresentation {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let step: Step
            let submission: Submission
        }

        struct ViewModel {
            let stepID: Step.IdType
            let submission: Submission
        }
    }

    /// Show submissions filter module
    enum FilterPresentation {
        struct Request {}

        struct Response {
            let step: Step
            let filters: [SubmissionsFilter.Filter]
        }

        struct ViewModel {
            let hasReview: Bool
            let filters: [SubmissionsFilter.Filter]
        }
    }

    /// Show active state for filter button
    enum FilterButtonActiveStatePresentation {
        struct Response {
            let isActive: Bool
        }

        struct ViewModel {
            let isActive: Bool
        }
    }

    /// Start search for submissions
    enum SearchSubmissions {
        struct Request {
            let text: String
            var forceSearch = false
        }
    }

    /// Set search text
    enum SearchTextUpdate {
        struct Response {
            let searchText: String
        }

        struct ViewModel {
            let searchText: String
        }
    }

    /// Show loading state
    enum LoadingStatePresentation {
        struct Response {}

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: - Types -

    struct SubmissionsData {
        let users: [User]
        let currentUserID: User.IdType?
        let submissions: [Submission]
        let instruction: InstructionDataPlainObject?
        let isTeacher: Bool
        let hasNextPage: Bool
    }

    struct SubmissionsResult {
        let submissions: [SubmissionViewModel]
        let isSubmissionsFilterAvailable: Bool
        let hasNextPage: Bool
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: SubmissionsResult)
    }

    enum PaginationState {
        case result(data: SubmissionsResult)
        case error
    }

    enum ReviewState {
        case evaluation
        case finished
        case inProgress
        case cantReviewWrong
        case cantReviewTeacher
        case cantReviewAnother
        case notSubmittedForReview

        var title: String {
            switch self {
            case .inProgress, .finished:
                return NSLocalizedString("SubmissionsReviewStateInProgressTitle", comment: "")
            case .notSubmittedForReview:
                return NSLocalizedString("SubmissionsReviewStateNotSubmittedForReviewTitle", comment: "")
            case .evaluation, .cantReviewWrong, .cantReviewTeacher, .cantReviewAnother:
                return NSLocalizedString("SubmissionsReviewStateCantReviewTitle", comment: "")
            }
        }

        var message: String {
            switch self {
            case .evaluation:
                return NSLocalizedString("SubmissionsReviewStateEvaluationMessage", comment: "")
            case .finished:
                return NSLocalizedString("SubmissionsReviewStateFinishedMessage", comment: "")
            case .inProgress:
                return NSLocalizedString("SubmissionsReviewStateInProgressMessage", comment: "")
            case .cantReviewWrong:
                return NSLocalizedString("SubmissionsReviewStateCantReviewWrongMessage", comment: "")
            case .cantReviewTeacher:
                return NSLocalizedString("SubmissionsReviewStateCantReviewTeacherMessage", comment: "")
            case .cantReviewAnother:
                return NSLocalizedString("SubmissionsReviewStateCantReviewAnotherMessage", comment: "")
            case .notSubmittedForReview:
                return NSLocalizedString("SubmissionsReviewStateNotSubmittedForReviewMessage", comment: "")
            }
        }

        var actionTitle: String {
            switch self {
            case .notSubmittedForReview:
                return NSLocalizedString("SubmissionsReviewActionSeeSubmissionTitle", comment: "")
            default:
                return NSLocalizedString("SubmissionsReviewActionSeeReviewsTitle", comment: "")
            }
        }
    }
}
