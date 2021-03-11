import Foundation

struct ReviewSessionDataPlainObject {
    let reviewSession: ReviewSessionPlainObject
    let submission: Submission?
    let attempt: Attempt?
    let givenReviews: [ReviewDataPlainObject]
    let takenReviews: [ReviewDataPlainObject]

    var id: Int { self.reviewSession.id }
}
