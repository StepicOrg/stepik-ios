import Foundation

struct ReviewDataPlainObject {
    let review: ReviewPlainObject
    let rubricScores: [RubricScorePlainObject]
    let submission: Submission?

    var id: Int { self.review.id }
}
