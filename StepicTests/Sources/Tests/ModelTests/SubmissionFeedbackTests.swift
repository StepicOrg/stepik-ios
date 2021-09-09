@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

class SubmissionFeedbackSpec: QuickSpec {
    override func spec() {
        describe("SubmissionFeedback") {
            describe("NSSecureCoding") {
                func makeTemporaryFile(name: String) -> URL {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return URL(fileURLWithPath: temporaryDirectoryPath.appendingPathComponent(name))
                }

                it("choice feedback encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"options_feedback":["502","5002","520","52"]}"#)
                    let choiceFeedback = ChoiceSubmissionFeedback(json: json)

                    let fileURL = makeTemporaryFile(name: "choice-submission-feedback")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: choiceFeedback,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedChoiceFeedback = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! ChoiceSubmissionFeedback

                    // Then
                    expect(unarchivedChoiceFeedback) == choiceFeedback
                    expect(unarchivedChoiceFeedback.options) == ["502", "5002", "520", "52"]
                }

                it("string feedback encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"feedback":"test feedback"}"#)
                    let stringFeedback = StringSubmissionFeedback(json: json["feedback"])

                    let fileURL = makeTemporaryFile(name: "string-submission-feedback")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: stringFeedback,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedStringFeedback = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! StringSubmissionFeedback

                    // Then
                    expect(unarchivedStringFeedback) == stringFeedback
                    expect(unarchivedStringFeedback.string) == "test feedback"
                }

                it("blanks feedback encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"blanks_feedback": [false, true]}"#)
                    let fillBlanksFeedback = FillBlanksFeedback(json: json)

                    let fileURL = makeTemporaryFile(name: "blanks-submission-feedback")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: fillBlanksFeedback,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedFillBlanksFeedback = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! FillBlanksFeedback

                    // Then
                    expect(unarchivedFillBlanksFeedback) == fillBlanksFeedback
                    expect(unarchivedFillBlanksFeedback.blanksCorrectness) == [false, true]
                }
            }
        }
    }
}
