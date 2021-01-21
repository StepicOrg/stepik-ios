import Nimble
import Quick
import SwiftyJSON

@testable import Stepic

class SubmissionFeedbackSpec: QuickSpec {
    override func spec() {
        describe("SubmissionFeedback") {
            describe("NSCoding") {
                func makeTemporaryPath(name: String) -> String {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return temporaryDirectoryPath.appendingPathComponent(name)
                }

                it("choice feedback encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"options_feedback":["502","5002","520","52"]}"#)
                    let choiceFeedback = ChoiceSubmissionFeedback(json: json)

                    let path = makeTemporaryPath(name: "choice-submission-feedback")

                    // When
                    NSKeyedArchiver.archiveRootObject(choiceFeedback, toFile: path)

                    let unarchivedChoiceFeedback = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! ChoiceSubmissionFeedback

                    // Then
                    expect(unarchivedChoiceFeedback) == choiceFeedback
                    expect(unarchivedChoiceFeedback.options) == ["502","5002","520","52"]
                }

                it("string feedback encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"feedback":"test feedback"}"#)
                    let stringFeedback = StringSubmissionFeedback(json: json["feedback"])

                    let path = makeTemporaryPath(name: "string-submission-feedback")

                    // When
                    NSKeyedArchiver.archiveRootObject(stringFeedback, toFile: path)

                    let unarchivedStringFeedback = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! StringSubmissionFeedback

                    // Then
                    expect(unarchivedStringFeedback) == stringFeedback
                    expect(unarchivedStringFeedback.string) == "test feedback"
                }

                it("blanks feedback encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"blanks_feedback": [false, true]}"#)
                    let fillBlanksFeedback = FillBlanksFeedback(json: json)

                    let path = makeTemporaryPath(name: "blanks-submission-feedback")

                    // When
                    NSKeyedArchiver.archiveRootObject(fillBlanksFeedback, toFile: path)

                    let unarchivedFillBlanksFeedback = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! FillBlanksFeedback

                    // Then
                    expect(unarchivedFillBlanksFeedback) == fillBlanksFeedback
                    expect(unarchivedFillBlanksFeedback.blanksCorrectness) == [false, true]
                }
            }
        }
    }
}
