@testable
import Stepic

import CoreData
import Nimble
import Quick
import SwiftyJSON

class SubmissionEntityTests: QuickSpec {
    override func spec() {
        describe("SubmissionEntity") {
            var testCoreDataStack: TestCoreDataStack!

            beforeEach {
                testCoreDataStack = TestCoreDataStack()
            }

            func makeSubmission(feedback: SubmissionFeedback?, reply: Reply?) -> Submission {
                Submission(
                    id: 1,
                    status: .correct,
                    score: 1,
                    hint: nil,
                    feedback: feedback,
                    time: Date(),
                    reply: reply,
                    attemptID: 1,
                    attempt: nil,
                    sessionID: nil,
                    isLocal: false
                )
            }

            context("SubmissionFeedbackValueTransformer") {
                it("persists SubmissionEntity with choice feedback") {
                    // Given
                    let choiceFeedback = ChoiceSubmissionFeedback(json: TestData.choiceSubmissionFeedback)
                    let submission = makeSubmission(feedback: choiceFeedback, reply: nil)

                    // When
                    _ = SubmissionEntity(
                        submission: submission,
                        managedObjectContext: testCoreDataStack.managedObjectContext
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.fetchRequest
                    request.sortDescriptors = SubmissionEntity.defaultSortDescriptors

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.feedback!.isEqual(choiceFeedback)) == true
                }

                it("persists SubmissionEntity with fill blanks feedback") {
                    // Given
                    let fillBlanksFeedback = FillBlanksFeedback(json: TestData.fillBlanksSubmissionFeedback)
                    let submission = makeSubmission(feedback: fillBlanksFeedback, reply: nil)

                    // When
                    _ = SubmissionEntity(
                        submission: submission,
                        managedObjectContext: testCoreDataStack.managedObjectContext
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.fetchRequest
                    request.sortDescriptors = SubmissionEntity.defaultSortDescriptors

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.feedback!.isEqual(fillBlanksFeedback)) == true
                }

                it("persists SubmissionEntity with string feedback") {
                    // Given
                    let stringFeedback = StringSubmissionFeedback(json: JSON("test"))
                    let submission = makeSubmission(feedback: stringFeedback, reply: nil)

                    // When
                    _ = SubmissionEntity(
                        submission: submission,
                        managedObjectContext: testCoreDataStack.managedObjectContext
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.fetchRequest
                    request.sortDescriptors = SubmissionEntity.defaultSortDescriptors

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.feedback!.isEqual(stringFeedback)) == true
                }
            }
        }
    }
}
