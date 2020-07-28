import Foundation

enum StepikSocialNetwork: String, CaseIterable, UniqueIdentifiable {
    case vk
    case facebook
    case instagram

    var uniqueIdentifier: UniqueIdentifierType { "\(self.rawValue)" }

    var url: URL? {
        switch self {
        case .vk:
            return URL(string: "https://vk.com/rustepik")
        case .facebook:
            return URL(string: "https://facebook.com/stepikorg")
        case .instagram:
            return URL(string: "https://instagram.com/stepik.education/")
        }
    }

    var icon: UIImage? {
        switch self {
        case .vk:
            return UIImage(named: "vk")
        case .facebook:
            return UIImage(named: "fb")
        case .instagram:
            return UIImage(named: "instagram")
        }
    }
}
