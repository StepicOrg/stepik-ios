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
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

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
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

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
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.feedback!.isEqual(stringFeedback)) == true
                }
            }

            context("ReplyValueTransformer") {
                it("persists SubmissionEntity with choice reply") {
                    // Given
                    let choiceReply = ChoiceReply(json: TestData.choiceReply)
                    let submission = makeSubmission(feedback: nil, reply: choiceReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(choiceReply)) == true
                }

                it("persists SubmissionEntity with code reply") {
                    // Given
                    let codeReply = CodeReply(json: TestData.codeReply)
                    let submission = makeSubmission(feedback: nil, reply: codeReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(codeReply)) == true
                }

                it("persists SubmissionEntity with fill blanks reply") {
                    // Given
                    let fillBlanksReply = FillBlanksReply(json: TestData.fillBlanksReply)
                    let submission = makeSubmission(feedback: nil, reply: fillBlanksReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(fillBlanksReply)) == true
                }

                it("persists SubmissionEntity with free answer reply") {
                    // Given
                    let freeAnswerReply = FreeAnswerReply(json: TestData.freeAnswerReply)
                    let submission = makeSubmission(feedback: nil, reply: freeAnswerReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(freeAnswerReply)) == true
                }

                it("persists SubmissionEntity with matching reply") {
                    // Given
                    let matchingReply = MatchingReply(json: TestData.matchingReply)
                    let submission = makeSubmission(feedback: nil, reply: matchingReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(matchingReply)) == true
                }

                it("persists SubmissionEntity with math reply") {
                    // Given
                    let mathReply = MathReply(json: TestData.mathReply)
                    let submission = makeSubmission(feedback: nil, reply: mathReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(mathReply)) == true
                }

                it("persists SubmissionEntity with number reply") {
                    // Given
                    let numberReply = NumberReply(json: TestData.numberReply)
                    let submission = makeSubmission(feedback: nil, reply: numberReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(numberReply)) == true
                }

                it("persists SubmissionEntity with sorting reply") {
                    // Given
                    let sortingReply = SortingReply(json: TestData.sortingReply)
                    let submission = makeSubmission(feedback: nil, reply: sortingReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(sortingReply)) == true
                }

                it("persists SubmissionEntity with SQL reply") {
                    // Given
                    let sqlReply = SQLReply(json: TestData.sqlReply)
                    let submission = makeSubmission(feedback: nil, reply: sqlReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(sqlReply)) == true
                }

                it("persists SubmissionEntity with table reply") {
                    // Given
                    let tableReply = TableReply(json: TestData.tableReply)
                    let submission = makeSubmission(feedback: nil, reply: tableReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(tableReply)) == true
                }

                it("persists SubmissionEntity with text reply") {
                    // Given
                    let textReply = TextReply(json: TestData.textReply)
                    let submission = makeSubmission(feedback: nil, reply: textReply)

                    // When
                    _ = SubmissionEntity.insert(
                        into: testCoreDataStack.managedObjectContext,
                        submission: submission
                    )
                    testCoreDataStack.saveContext()

                    // Then
                    let request = SubmissionEntity.sortedFetchRequest

                    let submissions = try! testCoreDataStack.managedObjectContext.fetch(request)
                    expect(submissions.count) == 1

                    let fetchedSubmission = submissions[0]

                    expect(fetchedSubmission.plainObject) == submission
                    expect(fetchedSubmission.reply!.isEqual(textReply)) == true
                }
            }
        }
    }
}
