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

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case anonymous
        case result(data: NewProfileViewModel)
    }
}
