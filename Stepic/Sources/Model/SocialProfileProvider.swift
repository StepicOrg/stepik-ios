import Foundation

enum SocialProfileProvider: String {
    case facebook
    case github
    case vk
    case twitter
    case instagram
    case skype
    case telegram
    case website

    var iconName: String {
        switch self {
        case .github:
            return "github"
        default:
            return "social-profile-provider-\(self.rawValue)"
        }
    }
}
