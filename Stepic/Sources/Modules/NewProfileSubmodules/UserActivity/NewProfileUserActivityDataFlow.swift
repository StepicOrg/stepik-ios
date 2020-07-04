import Foundation

enum NewProfileUserActivity {
    /// Show user activity
    enum ActivityLoad {
        struct Request {}

        struct Response {
            let result: Result<UserActivity, Error>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case error
        case result(data: NewProfileUserActivityViewModel)
    }
}
