import Foundation

enum NewProfile {
    // MARK: Common types

    enum Submodule: String, UniqueIdentifiable {
        case streakNotifications
        case userActivity
        case details

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

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

        struct Data {
            let user: User
            let isCurrentUserProfile: Bool
        }

        struct Response {
            let result: Result<Data, Error>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Register submodules
    enum SubmoduleRegistration {
        struct Request {
            var submodules: [UniqueIdentifierType: NewProfileSubmoduleProtocol]
        }
    }

    /// Try to set online mode
    enum OnlineModeReset {
        struct Request {}
    }

    /// Update navigation bar button items
    enum NavigationControlsPresentation {
        struct Response {
            let shouldPresentSettings: Bool
            let shouldPresentEditProfile: Bool
            let shouldPresentShareProfile: Bool
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

    /// Share profile
    enum ProfileShareAction {
        struct Request {}

        struct Response {
            let userID: User.IdType
        }

        struct ViewModel {
            let urlPath: String
        }
    }

    /// Edit profile
    enum ProfileEditAction {
        struct Request {}

        struct Response {
            let profile: Profile
        }

        struct ViewModel {
            let profile: Profile
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case anonymous
        case result(data: NewProfileViewModel)
    }
}
