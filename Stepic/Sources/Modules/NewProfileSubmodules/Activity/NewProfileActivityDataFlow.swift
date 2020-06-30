import Foundation

enum NewProfileActivity {
    /// Show user activity
    enum ActivityLoad {
        struct Request {}

        struct Response {
            let result: Result<UserActivity, Error>
        }

        struct ViewModel {}
    }
}
