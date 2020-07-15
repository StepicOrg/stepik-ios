import Foundation

enum NewProfileUserActivity {
    /// Show user activity
    enum ActivityLoad {
        struct Request {}

        struct Data {
            let userActivity: UserActivity
            let isCurrentUserProfile: Bool
        }

        struct Response {
            let result: Result<Data, Error>
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
