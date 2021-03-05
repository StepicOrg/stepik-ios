import Foundation
import SwiftyJSON

struct ReviewSessionPlainObject: Equatable {
    let id: Int
    let instruction: Int
    let submission: Int

    let givenReviews: [Int]
    let isGivingStarted: Bool
    let isGivingFinished: Bool

    let takenReviews: [Int]
    let isTakingStarted: Bool
    let isTakingFinished: Bool
    let isTakingFinishedByTeacher: Bool
    let whenTakingFinishedByTeacher: Date?

    let isReviewAvailable: Bool
    let isFinished: Bool

    let score: Float

    let availableReviewsCount: Int?

    let activeReview: Int?

    let actions: Actions

    struct Actions: Equatable {
        let finish: Bool
    }
}

extension ReviewSessionPlainObject {
    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.instruction = json[JSONKey.instruction.rawValue].intValue
        self.submission = json[JSONKey.submission.rawValue].intValue

        self.givenReviews = json[JSONKey.givenReviews.rawValue].arrayValue.compactMap(\.int)
        self.isGivingStarted = json[JSONKey.isGivingStarted.rawValue].boolValue
        self.isGivingFinished = json[JSONKey.isGivingFinished.rawValue].boolValue

        self.takenReviews = json[JSONKey.takenReviews.rawValue].arrayValue.compactMap(\.int)
        self.isTakingStarted = json[JSONKey.isTakingStarted.rawValue].boolValue
        self.isTakingFinished = json[JSONKey.isTakingFinished.rawValue].boolValue
        self.isTakingFinishedByTeacher = json[JSONKey.isTakingFinishedByTeacher.rawValue].boolValue
        self.whenTakingFinishedByTeacher = Parser.shared.dateFromTimedateJSON(
            json[JSONKey.whenTakingFinishedByTeacher.rawValue]
        )

        self.isReviewAvailable = json[JSONKey.isReviewAvailable.rawValue].boolValue
        self.isFinished = json[JSONKey.isFinished.rawValue].boolValue

        self.score = json[JSONKey.score.rawValue].floatValue
        self.availableReviewsCount = json[JSONKey.availableReviewsCount.rawValue].int
        self.activeReview = json[JSONKey.activeReview.rawValue].int

        var finishActionValue = false
        if let actionsDict = json[JSONKey.actions.rawValue].dictionaryObject {
            finishActionValue = actionsDict[JSONKey.finish.rawValue] as? Bool ?? false
        }
        self.actions = .init(finish: finishActionValue)
    }

    enum JSONKey: String {
        case id
        case instruction
        case submission
        case givenReviews = "given_reviews"
        case isGivingStarted = "is_giving_started"
        case isGivingFinished = "is_giving_finished"
        case takenReviews = "taken_reviews"
        case isTakingStarted = "is_taking_started"
        case isTakingFinished = "is_taking_finished"
        case isTakingFinishedByTeacher = "is_taking_finished_by_teacher"
        case whenTakingFinishedByTeacher = "when_taking_finished_by_teacher"
        case isReviewAvailable = "is_review_available"
        case isFinished = "is_finished"
        case score
        case availableReviewsCount = "available_reviews_count"
        case activeReview = "active_review"
        case actions
        case finish
    }
}
