import Foundation
import SwiftyJSON

struct ReviewsResponse {
    let reviews: [ReviewPlainObject]
    let attempts: [Attempt]
    let rubricScores: [RubricScorePlainObject]
    let submissions: [Submission]

    init(json: JSON, blockName: String) {
        self.reviews = json[JSONKey.reviews.rawValue].arrayValue.map(ReviewPlainObject.init)
        self.attempts = json[JSONKey.attempts.rawValue].arrayValue.map {
            Attempt(json: $0, stepBlockName: blockName)
        }
        self.rubricScores = json[JSONKey.rubricScores.rawValue].arrayValue.map(RubricScorePlainObject.init)
        self.submissions = json[JSONKey.submissions.rawValue].arrayValue.map {
            Submission(json: $0, stepBlockName: blockName)
        }
    }

    enum JSONKey: String {
        case reviews
        case attempts
        case rubricScores = "rubric-scores"
        case submissions
    }
}
