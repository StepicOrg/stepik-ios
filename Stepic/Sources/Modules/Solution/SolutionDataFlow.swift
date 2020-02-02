import Foundation

enum Solution {
    enum SolutionLoad {
        struct Data {
            let step: Step
            let submission: Submission
            let discussionID: DiscussionThread.IdType
        }

        struct Request {}

        struct Response {
            let result: Result<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum ViewControllerState {
        case loading
        case result(data: SolutionViewModel)
        case error
    }
}
