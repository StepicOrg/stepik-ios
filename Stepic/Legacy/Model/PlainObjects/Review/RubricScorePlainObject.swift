import Foundation
import SwiftyJSON

struct RubricScorePlainObject: Equatable {
    let id: Int
    let review: Int
    let rubric: Int
    let score: Float
    let text: String
}

extension RubricScorePlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.review = json[JSONKey.review.rawValue].intValue
        self.rubric = json[JSONKey.rubric.rawValue].intValue
        self.score = json[JSONKey.score.rawValue].floatValue
        self.text = json[JSONKey.text.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case review
        case rubric
        case score
        case text
    }
}
