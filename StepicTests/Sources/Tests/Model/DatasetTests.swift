import Nimble
import Quick
import SwiftyJSON

@testable import Stepic

class DatasetSpec: QuickSpec {
    override func spec() {
        describe("Dataset") {
            describe("NSCopying") {
                it("copies dataset") {
                    // Given
                    let dataset = Dataset()

                    // When
                    let datasetCopy = dataset.copy() as! Dataset

                    // Then
                    expect(dataset !== datasetCopy).to(beTrue())
                }

                it("copies choice dataset") {
                    // Given
                    let choiceDataset = ChoiceDataset(json: JSON({}))
                    choiceDataset.isMultipleChoice = true
                    choiceDataset.options = ["502", "5002", "520", "52"]

                    // When
                    let choiceDatasetCopy = choiceDataset.copy() as! ChoiceDataset

                    // Then
                    expect(choiceDataset !== choiceDatasetCopy).to(beTrue())
                    expect(choiceDataset.isEqual(choiceDatasetCopy)).to(beTrue())
                }

                it("copies fill blanks dataset") {
                    // Given
                    let textComponent = FillBlanksComponent(json: JSON({}))
                    textComponent.componentType = .text
                    textComponent.text = "<strong>2 + 2</strong> ="
                    textComponent.options = []

                    let selectComponent = FillBlanksComponent(json: JSON({}))
                    selectComponent.componentType = .select
                    selectComponent.text = ""
                    selectComponent.options = ["4", "5", "6"]

                    let fillBlanksDataset = FillBlanksDataset(json: JSON({}))
                    fillBlanksDataset.components = [textComponent, selectComponent]

                    // When
                    let fillBlanksDatasetCopy = fillBlanksDataset.copy() as! FillBlanksDataset

                    // Then
                    expect(fillBlanksDataset !== fillBlanksDatasetCopy).to(beTrue())
                    expect(fillBlanksDataset.isEqual(fillBlanksDatasetCopy)).to(beTrue())
                }

                it("copies free answer dataset") {
                    // Given
                    let freeAnswerDataset = FreeAnswerDataset(json: JSON({}))
                    freeAnswerDataset.isHTMLEnabled = true
                    freeAnswerDataset.isAttachmentsEnabled = true

                    // When
                    let freeAnswerDatasetCopy = freeAnswerDataset.copy() as! FreeAnswerDataset

                    // Then
                    expect(freeAnswerDataset !== freeAnswerDatasetCopy).to(beTrue())
                    expect(freeAnswerDataset.isEqual(freeAnswerDatasetCopy)).to(beTrue())
                }

                it("copies matching dataset") {
                    // Given
                    let matchingDataset = MatchingDataset(json: JSON({}))
                    matchingDataset.pairs = [("Sky", "Blue")]

                    // When
                    let matchingDatasetCopy = matchingDataset.copy() as! MatchingDataset

                    // Then
                    expect(matchingDataset !== matchingDatasetCopy).to(beTrue())
                    expect(matchingDataset.isEqual(matchingDatasetCopy)).to(beTrue())
                }

                it("copies sorting dataset") {
                    // Given
                    let sortingDataset = SortingDataset(json: JSON({}))
                    sortingDataset.options = ["Four", "Three", "One", "Two"]

                    // When
                    let sortingDatasetCopy = sortingDataset.copy() as! SortingDataset

                    // Then
                    expect(sortingDataset !== sortingDatasetCopy).to(beTrue())
                    expect(sortingDataset.isEqual(sortingDatasetCopy)).to(beTrue())
                }

                it("copies string dataset") {
                    // Given
                    let stringDataset = StringDataset(json: JSON({}))
                    stringDataset.string = "string"

                    // When
                    let stringDatasetCopy = stringDataset.copy() as! StringDataset

                    // Then
                    expect(stringDataset !== stringDatasetCopy).to(beTrue())
                    expect(stringDataset.isEqual(stringDatasetCopy)).to(beTrue())
                }

                it("copies table dataset") {
                    // Given
                    let tableDataset = TableDataset(json: JSON({}))
                    tableDataset.datasetDescription = "description"
                    tableDataset.rows = ["Traffic lights", "Women's dress", "Sun", "Grass"]
                    tableDataset.columns = ["Red", "Blue", "Green"]
                    tableDataset.isCheckbox = true

                    // When
                    let tableDatasetCopy = tableDataset.copy() as! TableDataset

                    // Then
                    expect(tableDataset !== tableDatasetCopy).to(beTrue())
                    expect(tableDataset.isEqual(tableDatasetCopy)).to(beTrue())
                }
            }

            describe("NSCoding") {
                func makeTemporaryPath(name: String) -> String {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return temporaryDirectoryPath.appendingPathComponent(name)
                }

                it("choice dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"is_multiple_choice":false,"options":["502","5002","520","52"]}"#)
                    let choiceDataset = ChoiceDataset(json: json)

                    let path = makeTemporaryPath(name: "choice-dataset")

                    // When
                    NSKeyedArchiver.archiveRootObject(choiceDataset, toFile: path)

                    let unarchivedChoiceDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! ChoiceDataset

                    // Then
                    expect(unarchivedChoiceDataset) == choiceDataset
                    expect(unarchivedChoiceDataset.isMultipleChoice) == false
                    expect(unarchivedChoiceDataset.options) == ["502","5002","520","52"]
                }

                it("fill blanks dataset encoded and decoded") {
                    // Given
                    let jsonString = #"""
      {
        "components": [
          {
            "type": "text",
            "text": "<strong>2 + 2</strong> =",
            "options": []
          },
          {
            "type": "input",
            "text": "",
            "options": []
          },
          {
            "type": "text",
            "text": "3 + 3 =",
            "options": []
          },
          {
            "type": "select",
            "text": "",
            "options": [
              "4",
              "5",
              "6"
            ]
          }
        ]
      }
"""#
                    let json = JSON(parseJSON: jsonString)
                    let fillBlanksDataset = FillBlanksDataset(json: json)

                    let path = makeTemporaryPath(name: "fill-blanks-dataset")

                    // When
                    NSKeyedArchiver.archiveRootObject(fillBlanksDataset, toFile: path)

                    let unarchivedDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! FillBlanksDataset

                    // Then
                    expect(unarchivedDataset) == fillBlanksDataset
                    expect(unarchivedDataset.components.count) == 4
                }

                it("string dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"dataset": "string value"}"#)
                    let stringDataset = StringDataset(json: json["dataset"])

                    let path = makeTemporaryPath(name: "string-dataset")

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

                    let path = makeTemporaryPath(name: "sorting-dataset")

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

                    let path = makeTemporaryPath(name: "freeAnswer-dataset")

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

                    let path = makeTemporaryPath(name: "matching-dataset")

                    // When
                    NSKeyedArchiver.archiveRootObject(matchingDataset, toFile: path)

                    let unarchivedMatchingDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! MatchingDataset

                    // Then
                    expect(unarchivedMatchingDataset) == matchingDataset
                    expect(unarchivedMatchingDataset.firstValues) == ["Sky", "Sun", "Grass"]
                    expect(unarchivedMatchingDataset.secondValues) == ["Green", "Orange", "Blue"]
                }

                it("table dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"description":"Table:","rows":["Traffic lights","Women's dress","Sun","Grass"],"columns":["Red","Blue","Green"],"is_checkbox":true}"#)
                    let tableDataset = TableDataset(json: json)

                    let path = makeTemporaryPath(name: "table-dataset")

                    // When
                    NSKeyedArchiver.archiveRootObject(tableDataset, toFile: path)

                    let unarchivedTableDataset = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! TableDataset

                    // Then
                    expect(unarchivedTableDataset) == tableDataset
                    expect(unarchivedTableDataset.datasetDescription) == "Table:"
                    expect(unarchivedTableDataset.rows) == ["Traffic lights", "Women's dress", "Sun", "Grass"]
                    expect(unarchivedTableDataset.columns) == ["Red", "Blue", "Green"]
                    expect(unarchivedTableDataset.isCheckbox) == true
                }
            }
        }
    }
}
