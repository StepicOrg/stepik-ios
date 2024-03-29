import Foundation

enum NewProfile {
    // MARK: Common types

    enum Submodule: String, UniqueIdentifiable {
        case streakNotifications
        case createdCourses
        case userActivity
        case achievements
        case certificates
        case socialProfiles
        case details

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }
    }

    // Use it for module initializing
    struct PresentationDescription {
        let profileType: ProfileType

        enum ProfileType {
            case currentUser
            case otherUser(profileUserID: User.IdType)

            var isCurrentUser: Bool {
                if case .currentUser = self {
                    return true
                }
                return false
            }
        }
    }

    // MARK: Use cases

    /// Load & show info about profile
    enum ProfileLoad {
        struct Request {
            var forceUpdate = false
        }

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

    /// Fetch user profile updates in the background
    enum ProfileFetchUpdates {
        struct Request {}
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

    /// Present empty state for submodule
    enum SubmoduleEmptyStatePresentation {
        struct Response {
            let module: Submodule
        }

        struct ViewModel {
            let module: Submodule
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

    /// Show all achievements in a details list controller
    enum AchievementsListPresentation {
        struct Request {}

        struct Response {
            let userID: User.IdType
        }

        struct ViewModel {
            let userID: User.IdType
        }
    }

    /// Show all certificates in a details list controller
    enum CertificatesListPresentation {
        struct Request {}

        struct Response {
            let userID: User.IdType
        }

        struct ViewModel {
            let userID: User.IdType
        }
    }

    // Handle UIRefreshControl
    enum RefreshControlUpdate {
        struct Response {
            let shouldEndRefreshing: Bool
        }

        struct ViewModel {
            let shouldEndRefreshing: Bool
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
