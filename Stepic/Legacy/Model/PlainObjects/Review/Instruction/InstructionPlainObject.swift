import Foundation
import SwiftyJSON

struct InstructionPlainObject: Equatable {
    let id: Int
    let step: Int
    let minReviews: Int
    let strategyType: String
    let rubrics: [Int]
    let isFrozen: Bool
    let text: String
}

extension InstructionPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.step = json[JSONKey.step.rawValue].intValue
        self.minReviews = json[JSONKey.minReviews.rawValue].intValue
        self.strategyType = json[JSONKey.strategyType.rawValue].stringValue
        self.rubrics = json[JSONKey.rubrics.rawValue].arrayValue.compactMap(\.int)
        self.isFrozen = json[JSONKey.isFrozen.rawValue].boolValue
        self.text = json[JSONKey.text.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case step
        case minReviews = "min_reviews"
        case strategyType = "strategy_type"
        case rubrics
        case isFrozen = "is_frozen"
        case text
    }
}
