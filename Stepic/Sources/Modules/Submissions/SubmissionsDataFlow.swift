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
        let submissions: [Submission]
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
}
