import Foundation
import SwiftyJSON

struct Meta: Codable {
    let page: Int
    let hasNext: Bool
    let hasPrevious: Bool

    static var oneAndOnlyPage: Meta {
        Meta(page: 1, hasNext: false, hasPrevious: false)
    }

    enum CodingKeys: String, CodingKey {
        case page
        case hasNext = "has_next"
        case hasPrevious = "has_previous"
    }
}

extension Meta {
    init(json: JSON) {
        self.page = json[CodingKeys.page.rawValue].intValue
        self.hasNext = json[CodingKeys.hasNext.rawValue].boolValue
        self.hasPrevious = json[CodingKeys.hasPrevious.rawValue].boolValue
    }
}
