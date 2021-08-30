import Foundation
import SwiftyJSON

struct Meta {
    let hasNext: Bool
    let hasPrev: Bool
    let page: Int

    static var oneAndOnlyPage: Meta {
        Meta(hasNext: false, hasPrev: false, page: 1)
    }

    init(hasNext: Bool, hasPrev: Bool, page: Int) {
        self.hasNext = hasNext
        self.hasPrev = hasPrev
        self.page = page
    }

    init(json: JSON) {
        self.hasNext = json[JSONKey.hasNext.rawValue].boolValue
        self.hasPrev = json[JSONKey.hasPrevious.rawValue].boolValue
        self.page = json[JSONKey.page.rawValue].intValue
    }

    enum JSONKey: String {
        case meta
        case hasNext = "has_next"
        case hasPrevious = "has_previous"
        case page
    }
}
