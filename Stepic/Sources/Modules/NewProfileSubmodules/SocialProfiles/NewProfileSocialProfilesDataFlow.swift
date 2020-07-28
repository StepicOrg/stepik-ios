import Foundation

enum NewProfileSocialProfiles {
    /// Show social profiles
    enum SocialProfilesLoad {
        struct Request {}

        struct Response {
            let result: Result<[SocialProfile], Error>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewProfileSocialProfilesViewModel)
    }
}
