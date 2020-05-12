import Foundation

enum NewProfile {
    // MARK: Common structs

    // Use it for module initializing
    struct PresentationDescription {
        let profileType: ProfileType

        enum ProfileType {
            case currentUser
            case otherUser(profileUserID: User.IdType)
        }
    }

    // MARK: Use cases

    /// Load & show info about profile
    enum ProfileLoad {
        struct Request {}

        struct Response {
            let result: Result<User, Error>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Try to set online mode
    enum OnlineModeReset {
        struct Request {}
    }

    /// Update navigation bar button items.
    enum NavigationControlsPresentation {
        struct Response {
            let shoouldPresentSettings: Bool
            let shoouldPresentEditProfile: Bool
            let shoouldPresentShareProfile: Bool
        }

        struct ViewModel {
            let isSettingsAvailable: Bool
            let isEditProfileAvailable: Bool
            let isShareProfileAvailable: Bool
        }
    }

    /// Present authorization controller
    enum AuthorizationPresentation {
        struct Response {}

        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case anonymous
        case result(data: NewProfileViewModel)
    }
}
