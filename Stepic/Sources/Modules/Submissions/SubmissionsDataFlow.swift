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

    // MARK: - Types -

    struct SubmissionsData {
        let user: User
        let submissions: [Submission]
        let hasNextPage: Bool
    }

    struct SubmissionsResult {
        let submissions: [SubmissionsViewModel]
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
