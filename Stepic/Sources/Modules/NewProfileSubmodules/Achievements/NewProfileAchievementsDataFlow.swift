import Foundation

enum NewProfileAchievements {
    /// Show achievements
    enum AchievementsLoad {
        struct Request {}

        struct Response {
            let result: Result<[AchievementProgressData], Error>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Show detail achievement alert
    enum AchievementPresentation {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let achievementProgressData: AchievementProgressData
            let isShareable: Bool
        }

        struct ViewModel {
            let achievement: AchievementViewData
            let isShareable: Bool
        }
    }

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewProfileAchievementsViewModel)
    }
}
