import Foundation
import SwiftyJSON

struct MobileTierCalculateResponse {
    let mobileTiers: [MobileTierPlainObject]

    init(json: JSON) {
        self.mobileTiers = json[JSONKey.mobileTiers.rawValue].arrayValue.map(MobileTierPlainObject.init)
    }

    enum JSONKey: String {
        case mobileTiers = "mobile-tiers"
    }
}
