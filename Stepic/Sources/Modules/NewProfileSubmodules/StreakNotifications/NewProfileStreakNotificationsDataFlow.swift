import Foundation

enum NewProfileStreakNotifications {
    /// Show streak notifications
    enum StreakNotificationsLoad {
        struct Request {}

        struct Response {
            let isStreakNotificationsEnabled: Bool
            let streaksNotificationsStartHour: Int
        }

        struct ViewModel {
            let viewModel: NewProfileStreakNotificationsViewModel
        }
    }

    /// Set streak notifications on or off
    enum StreakNotificationsPreferenceUpdate {
        struct Request {
            let isOn: Bool
        }
    }
}
