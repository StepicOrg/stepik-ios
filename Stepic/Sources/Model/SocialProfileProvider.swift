import Foundation

enum SocialProfileProvider: String {
    case facebook
    case instagram
    case twitter
    case vk
    case website

    var importanceValue: Int {
        switch self {
        case .facebook:
            return 4
        case .instagram:
            return 3
        case .twitter:
            return 2
        case .vk:
            return 1
        case .website:
            return 0
        }
    }
}
