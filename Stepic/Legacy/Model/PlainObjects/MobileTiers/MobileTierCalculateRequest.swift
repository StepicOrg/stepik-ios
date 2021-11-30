import Foundation

struct MobileTierCalculateRequest {
    let params: [Param]

    var bodyJSON: [JSONDictionary] {
        self.params.map { param in
            var dict: JSONDictionary = [
                JSONKey.course.rawValue: param.courseID,
                JSONKey.store.rawValue: PaymentStore.appStore.rawValue
            ]

            if let promoCodeName = param.promoCodeName {
                dict[JSONKey.promo.rawValue] = promoCodeName
            }

            return dict
        }
    }

    struct Param {
        let courseID: Int
        let promoCodeName: String?
    }

    enum JSONKey: String {
        case course
        case store
        case promo
    }
}
