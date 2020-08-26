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

    /// Show change streak notifications time controller
    enum SelectStreakNotificationsTimePresentation {
        struct Request {}

        struct Response {
            let startHour: Int
        }

        struct ViewModel {
            let startHour: Int
        }
    }

    /// Check for tooltip
    enum TooltipAvailabilityCheck {
        struct Request {}

        struct Response {
            let shouldShowTooltip: Bool
        }

        struct ViewModel {
            let shouldShowTooltip: Bool
        }
    }
}
