import Foundation

struct PromoBanner: Decodable {
    let type: String
    let lang: String
    let title: String
    let description: String
    let url: String
    let screen: String
    let position: Int

    var screenType: ScreenType? { ScreenType(rawValue: self.screen) }

    enum ScreenType: String {
        case home
        case catalog
    }
}
