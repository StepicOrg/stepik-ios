import Foundation

struct ReviewDataPlainObject {
    let review: ReviewPlainObject
    let rubricScores: [RubricScorePlainObject]

    var id: Int { self.review.id }
}
