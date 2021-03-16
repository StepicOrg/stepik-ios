@testable
import Stepic

import Foundation
import Nimble
import Quick
import SwiftyJSON

class ReviewSessionResponseSpec: QuickSpec {
    override func spec() {
        describe("ReviewSessionResponse") {
            it("successfully parses review sessions") {
                // Given
                let json = TestData.reviewSessionsResponse
                let blockName = BlockType.choice.rawValue

                // When
                let response = ReviewSessionResponse(
                    json: json,
                    blockName: blockName
                )

                // Then
                expect(response.reviewSessions.count) == 4
                expect(response.attempts.count) == 4
                expect(response.reviews.count) == 12
                expect(response.rubricScores.count) == 12
                expect(response.submissions.count) == 4

                expect(response.reviewSessions[0]) == ReviewSessionPlainObject(
                    id: 908582,
                    instruction: 26700,
                    submission: 376038909,
                    givenReviews: [1720159],
                    isGivingStarted: true,
                    isGivingFinished: false,
                    takenReviews: [1720161],
                    isTakingStarted: true,
                    isTakingFinished: false,
                    isTakingFinishedByTeacher: false,
                    whenTakingFinishedByTeacher: nil,
                    isReviewAvailable: false,
                    isFinished: false,
                    score: 0,
                    availableReviewsCount: nil,
                    activeReview: 1720160,
                    actions: .init(finish: false)
                )

                expect(response.attempts[0]) == Attempt(
                    id: 359944920,
                    dataset: ChoiceDataset(isMultipleChoice: false, options: ["520", "52", "502", "5002"]),
                    datasetURL: nil,
                    time: "2021-03-04T20:11:55Z",
                    status: "active",
                    stepID: 1979373,
                    timeLeft: nil,
                    userID: 52444375
                )

                expect(response.reviews[0]) == ReviewPlainObject(
                    id: 1720129,
                    session: nil,
                    targetSession: nil,
                    text: "<p>General comments</p>\n\n<p><strong>General</strong> <u>comments <span style=\"background-color: #f3f4f6; font-size: 14.399999618530273px;\">good</span></u></p>\n",
                    rubricScores: [3269032],
                    submission: nil,
                    whenFinished: Parser.dateFromTimedateJSON(JSON("2021-03-04T20:15:23Z")),
                    isVerified: false,
                    isFrozen: true
                )

                expect(response.rubricScores[0]) == RubricScorePlainObject(
                    id: 3269032,
                    review: 1720129,
                    rubric: 39550,
                    score: 3,
                    text: "Detailed explanation of the score"
                )

                expect(response.submissions[0]) == Submission(
                    id: 376034175,
                    status: .correct,
                    score: 1,
                    hint: "",
                    feedback: StringSubmissionFeedback(string: ""),
                    time: Parser.dateFromTimedateJSON(JSON("2021-03-04T20:11:58Z"))!,
                    reply: ChoiceReply(choices: [false, false, true, false]),
                    attemptID: 359944920,
                    attempt: nil,
                    sessionID: 908571,
                    isLocal: false
                )
            }
        }
    }
}
