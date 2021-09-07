@testable
import Stepic

import CoreData
import Nimble
import Quick
import SwiftyJSON

class AttemptEntitySpec: QuickSpec {
    override func spec() {
        describe("AttemptEntity") {
            var testCoreDataStack: TestCoreDataStack!

            beforeEach {
                testCoreDataStack = TestCoreDataStack()
            }

            func makeAttempt(dataset: Dataset?) -> Attempt {
                Attempt(
                    id: 1,
                    dataset: dataset,
                    datasetURL: nil,
                    time: nil,
                    status: nil,
                    stepID: 1,
                    timeLeft: nil,
                    userID: 1
                )
            }

            it("persists AttemptEntity with choice dataset") {
                // Given
                let choiceDataset = ChoiceDataset(json: TestData.choiceDataset)
                let attempt = makeAttempt(dataset: choiceDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(choiceDataset)) == true
            }

            it("persists AttemptEntity with fill blanks dataset") {
                // Given
                let fillBlanksDataset = FillBlanksDataset(json: TestData.fillBlanksDataset)
                let attempt = makeAttempt(dataset: fillBlanksDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(fillBlanksDataset)) == true
            }

            it("persists AttemptEntity with free answer dataset") {
                // Given
                let freeAnswerDataset = FreeAnswerDataset(json: TestData.freeAnswerDataset)
                let attempt = makeAttempt(dataset: freeAnswerDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(freeAnswerDataset)) == true
            }

            it("persists AttemptEntity with matching dataset") {
                // Given
                let matchingDataset = MatchingDataset(json: TestData.matchingDataset)
                let attempt = makeAttempt(dataset: matchingDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(matchingDataset)) == true
            }

            it("persists AttemptEntity with sorting dataset") {
                // Given
                let sortingDataset = SortingDataset(json: TestData.sortingDataset)
                let attempt = makeAttempt(dataset: sortingDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(sortingDataset)) == true
            }

            it("persists AttemptEntity with string dataset") {
                // Given
                let stringDataset = StringDataset(json: JSON("test"))
                let attempt = makeAttempt(dataset: stringDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(stringDataset)) == true
            }

            it("persists AttemptEntity with table dataset") {
                // Given
                let tableDataset = TableDataset(json: TestData.tableDataset)
                let attempt = makeAttempt(dataset: tableDataset)

                // When
                _ = AttemptEntity.insert(
                    into: testCoreDataStack.managedObjectContext,
                    attempt: attempt
                )
                testCoreDataStack.saveContext()

                // Then
                let request = AttemptEntity.sortedFetchRequest

                let attempts = try! testCoreDataStack.managedObjectContext.fetch(request)
                expect(attempts.count) == 1

                let fetchedAttempt = attempts[0]

                expect(fetchedAttempt.id) == 1
                expect(fetchedAttempt.datasetURL).to(beNil())
                expect(fetchedAttempt.time).to(beNil())
                expect(fetchedAttempt.status).to(beNil())
                expect(fetchedAttempt.stepID) == 1
                expect(fetchedAttempt.timeLeftString).to(beNil())
                expect(fetchedAttempt.userID) == 1
                expect(fetchedAttempt.dataset!.isEqual(tableDataset)) == true
            }
        }
    }
}
