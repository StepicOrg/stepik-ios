import Foundation

enum Submissions {
    // MARK: Use Cases

    enum SubmissionsLoad {
        struct Request {}

        struct Data {
            let user: User
            let submissions: [Submission]
        }

        struct Response {
            let result: Result<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: Common Types

    struct SubmissionsResult {
        let submissions: [SubmissionsViewModel]
        let hasNextPage: Bool
    }

    enum ViewControllerState {
        case loading
        case error
        case result(data: SubmissionsResult)
    }
}
