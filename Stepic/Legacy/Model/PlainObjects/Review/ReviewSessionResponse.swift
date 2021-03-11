import Foundation
import SwiftyJSON

struct ReviewSessionResponse {
    let reviewSessions: [ReviewSessionPlainObject]
    let attempts: [Attempt]
    let reviews: [ReviewPlainObject]
    let rubricScores: [RubricScorePlainObject]
    let submissions: [Submission]

    init(json: JSON, blockName: String) {
        self.reviewSessions = json[JSONKey.reviewSessions.rawValue].arrayValue.map(ReviewSessionPlainObject.init)
        self.attempts = json[JSONKey.attempts.rawValue].arrayValue.map {
            Attempt(json: $0, stepBlockName: blockName)
        }
        self.reviews = json[JSONKey.reviews.rawValue].arrayValue.map(ReviewPlainObject.init)
        self.rubricScores = json[JSONKey.rubricScores.rawValue].arrayValue.map(RubricScorePlainObject.init)
        self.submissions = json[JSONKey.submissions.rawValue].arrayValue.map {
            Submission(json: $0, stepBlockName: blockName)
        }
    }

    enum JSONKey: String {
        case reviewSessions = "review-sessions"
        case attempts
        case reviews
        case rubricScores = "rubric-scores"
        case submissions
    }
}
