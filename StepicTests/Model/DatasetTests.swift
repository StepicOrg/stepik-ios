import Nimble
import Quick
import SwiftyJSON

@testable import Stepic

class DatasetSpec: QuickSpec {
    override func spec() {
        describe("Dataset") {
            describe("NSCoding") {
                func makeTemporaryPath(name: String) -> String {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return temporaryDirectoryPath.appendingPathComponent(name)
                }

                it("choice dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"is_multiple_choice":false,"options":["502","5002","520","52"]}"#)
                    let choiceDataset = ChoiceDataset(json: json)

                    let path = makeTemporaryPath(name: "choice")

                    // When
                    NSKeyedArchiver.archiveRootObject(choiceDataset, toFile: path)

                    let unarchivedChoiceDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! ChoiceDataset

                    // Then
                    expect(unarchivedChoiceDataset) == choiceDataset
                    expect(unarchivedChoiceDataset.isMultipleChoice) == false
                    expect(unarchivedChoiceDataset.options) == ["502","5002","520","52"]
                }

                it("string dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"dataset": "string value"}"#)
                    let stringDataset = StringDataset(json: json["dataset"])

                    let path = makeTemporaryPath(name: "string")

                    // When
                    NSKeyedArchiver.archiveRootObject(stringDataset, toFile: path)

                    let unarchivedStringDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! StringDataset

                    // Then
                    expect(unarchivedStringDataset) == stringDataset
                    expect(unarchivedStringDataset.string) == "string value"
                }

                it("sorting dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"options": ["Four <p><strong>HTML tags in items enabled.</strong></p>", "Three", "One", "Two"]}"#)
                    let sortingDataset = SortingDataset(json: json)

                    let path = makeTemporaryPath(name: "sorting")

                    // When
                    NSKeyedArchiver.archiveRootObject(sortingDataset, toFile: path)

                    let unarchivedSortingDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SortingDataset

                    // Then
                    expect(unarchivedSortingDataset) == sortingDataset
                    expect(unarchivedSortingDataset.options) == ["Four <p><strong>HTML tags in items enabled.</strong></p>", "Three", "One", "Two"]
                }

                it("free answer dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"is_attachments_enabled": false, "is_html_enabled": true}"#)
                    let freeAnswerDataset = FreeAnswerDataset(json: json)

                    let path = makeTemporaryPath(name: "freeAnswer")

                    // When
                    NSKeyedArchiver.archiveRootObject(freeAnswerDataset, toFile: path)

                    let unarchivedFreeAnswerDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! FreeAnswerDataset

                    // Then
                    expect(unarchivedFreeAnswerDataset) == freeAnswerDataset
                    expect(unarchivedFreeAnswerDataset.isAttachmentsEnabled) == false
                    expect(unarchivedFreeAnswerDataset.isHTMLEnabled) == true
                }

                it("matching dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"pairs": [{"first": "Sky", "second": "Green"}, {"first": "Sun", "second": "Orange"}, {"first": "Grass", "second": "Blue"}]}"#)
                    let matchingDataset = MatchingDataset(json: json)

                    let path = makeTemporaryPath(name: "matching")

                    // When
                    NSKeyedArchiver.archiveRootObject(matchingDataset, toFile: path)

                    let unarchivedMatchingDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! MatchingDataset

                    // Then
                    expect(unarchivedMatchingDataset) == matchingDataset
                    expect(unarchivedMatchingDataset.firstValues) == ["Sky", "Sun", "Grass"]
                    expect(unarchivedMatchingDataset.secondValues) == ["Green", "Orange", "Blue"]
                }
            }
        }
    }
}
