import Foundation

enum StoryOpenSource {
    case home
    case catalog
    case deeplink(path: String)

    var name: String {
        switch self {
        case .home:
            return "home"
        case .catalog:
            return "catalog"
        case .deeplink:
            return "deeplink"
        }
    }
}
