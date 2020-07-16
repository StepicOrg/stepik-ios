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

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewProfileAchievementsViewModel)
    }
}
