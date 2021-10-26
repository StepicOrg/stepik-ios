import Foundation
import SwiftyJSON

struct MobileTierPlainObject {
    let id: String
    let courseID: Int
    let priceTier: String?
    let promoTier: String?
}

extension MobileTierPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.priceTier = json[JSONKey.priceTier.rawValue].string
        self.promoTier = json[JSONKey.promoTier.rawValue].string
    }

    enum JSONKey: String {
        case id
        case course
        case priceTier = "price_tier"
        case promoTier = "promo_tier"
    }
}
