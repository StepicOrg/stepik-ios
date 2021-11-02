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
        self.priceTier = Self.sanitizedTier(json[JSONKey.priceTier.rawValue].string)
        self.promoTier = Self.sanitizedTier(json[JSONKey.promoTier.rawValue].string)

        if self.priceTier != nil {
            print("MobileTierPlainObject :: courseID = \(self.courseID)")
        }
    }

    // TODO: Remove before release
    private static func sanitizedTier(_ tier: String?) -> String? {
        guard let tier = tier else {
            return nil
        }

        var result = tier.lowercased()

        if result.starts(with: "tier ") {
            result = "course_\(result.replacingOccurrences(of: " ", with: "_"))"
        }

        assert(result.starts(with: "course_tier_"))
        print("MobileTierPlainObject :: tier = \(result)")

        return result
    }

    enum JSONKey: String {
        case id
        case course
        case priceTier = "price_tier"
        case promoTier = "promo_tier"
    }
}
