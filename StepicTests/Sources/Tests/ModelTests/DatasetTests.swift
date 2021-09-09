@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

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
                    expect(dataset !== datasetCopy) == true
                }

                it("copies choice dataset") {
                    // Given
                    let choiceDataset = ChoiceDataset(json: JSON({}))
                    choiceDataset.isMultipleChoice = true
                    choiceDataset.options = ["502", "5002", "520", "52"]

                    // When
                    let choiceDatasetCopy = choiceDataset.copy() as! ChoiceDataset

                    // Then
                    expect(choiceDataset !== choiceDatasetCopy) == true
                    expect(choiceDataset.isEqual(choiceDatasetCopy)) == true
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
                    expect(fillBlanksDataset !== fillBlanksDatasetCopy) == true
                    expect(fillBlanksDataset.isEqual(fillBlanksDatasetCopy)) == true
                }

                it("copies free answer dataset") {
                    // Given
                    let freeAnswerDataset = FreeAnswerDataset(json: JSON({}))
                    freeAnswerDataset.isHTMLEnabled = true
                    freeAnswerDataset.isAttachmentsEnabled = true

                    // When
                    let freeAnswerDatasetCopy = freeAnswerDataset.copy() as! FreeAnswerDataset

                    // Then
                    expect(freeAnswerDataset !== freeAnswerDatasetCopy) == true
                    expect(freeAnswerDataset.isEqual(freeAnswerDatasetCopy)) == true
                }

                it("copies matching dataset") {
                    // Given
                    let matchingDataset = MatchingDataset(json: JSON({}))
                    matchingDataset.pairs = [("Sky", "Blue")]

                    // When
                    let matchingDatasetCopy = matchingDataset.copy() as! MatchingDataset

                    // Then
                    expect(matchingDataset !== matchingDatasetCopy) == true
                    expect(matchingDataset.isEqual(matchingDatasetCopy)) == true
                }

                it("copies sorting dataset") {
                    // Given
                    let sortingDataset = SortingDataset(json: JSON({}))
                    sortingDataset.options = ["Four", "Three", "One", "Two"]

                    // When
                    let sortingDatasetCopy = sortingDataset.copy() as! SortingDataset

                    // Then
                    expect(sortingDataset !== sortingDatasetCopy) == true
                    expect(sortingDataset.isEqual(sortingDatasetCopy)) == true
                }

                it("copies string dataset") {
                    // Given
                    let stringDataset = StringDataset(json: JSON({}))
                    stringDataset.string = "string"

                    // When
                    let stringDatasetCopy = stringDataset.copy() as! StringDataset

                    // Then
                    expect(stringDataset !== stringDatasetCopy) == true
                    expect(stringDataset.isEqual(stringDatasetCopy)) == true
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
                    expect(tableDataset !== tableDatasetCopy) == true
                    expect(tableDataset.isEqual(tableDatasetCopy)) == true
                }
            }

            describe("NSSecureCoding") {
                func makeTemporaryFile(name: String) -> URL {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return URL(fileURLWithPath: temporaryDirectoryPath.appendingPathComponent(name))
                }

                it("choice dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"is_multiple_choice":false,"options":["502","5002","520","52"]}"#)
                    let choiceDataset = ChoiceDataset(json: json)

                    let fileURL = makeTemporaryFile(name: "choice-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: choiceDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedChoiceDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! ChoiceDataset

                    // Then
                    expect(unarchivedChoiceDataset) == choiceDataset
                    expect(unarchivedChoiceDataset.isMultipleChoice) == false
                    expect(unarchivedChoiceDataset.options) == ["502", "5002", "520", "52"]
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

                    let fileURL = makeTemporaryFile(name: "fill-blanks-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: fillBlanksDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedFillBlanksDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! FillBlanksDataset

                    // Then
                    expect(unarchivedFillBlanksDataset) == fillBlanksDataset
                    expect(unarchivedFillBlanksDataset.components.count) == 4
                }

                it("string dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"dataset": "string value"}"#)
                    let stringDataset = StringDataset(json: json["dataset"])

                    let fileURL = makeTemporaryFile(name: "string-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: stringDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedStringDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! StringDataset

                    // Then
                    expect(unarchivedStringDataset) == stringDataset
                    expect(unarchivedStringDataset.string) == "string value"
                }

                it("sorting dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"options": ["Four <p><strong>HTML tags in items enabled.</strong></p>", "Three", "One", "Two"]}"#)
                    let sortingDataset = SortingDataset(json: json)

                    let fileURL = makeTemporaryFile(name: "sorting-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: sortingDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedSortingDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! SortingDataset

                    // Then
                    expect(unarchivedSortingDataset) == sortingDataset
                    expect(unarchivedSortingDataset.options) == [
                        "Four <p><strong>HTML tags in items enabled.</strong></p>", "Three", "One", "Two"
                    ]
                }

                it("free answer dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"is_attachments_enabled": false, "is_html_enabled": true}"#)
                    let freeAnswerDataset = FreeAnswerDataset(json: json)

                    let fileURL = makeTemporaryFile(name: "freeAnswer-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: freeAnswerDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedFreeAnswerDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! FreeAnswerDataset

                    // Then
                    expect(unarchivedFreeAnswerDataset) == freeAnswerDataset
                    expect(unarchivedFreeAnswerDataset.isAttachmentsEnabled) == false
                    expect(unarchivedFreeAnswerDataset.isHTMLEnabled) == true
                }

                it("matching dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"pairs": [{"first": "Sky", "second": "Green"}, {"first": "Sun", "second": "Orange"}, {"first": "Grass", "second": "Blue"}]}"#)
                    let matchingDataset = MatchingDataset(json: json)

                    let fileURL = makeTemporaryFile(name: "matching-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: matchingDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedMatchingDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! MatchingDataset

                    // Then
                    expect(unarchivedMatchingDataset) == matchingDataset
                    expect(unarchivedMatchingDataset.firstValues) == ["Sky", "Sun", "Grass"]
                    expect(unarchivedMatchingDataset.secondValues) == ["Green", "Orange", "Blue"]
                }

                it("table dataset encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"description":"Table:","rows":["Traffic lights","Women's dress","Sun","Grass"],"columns":["Red","Blue","Green"],"is_checkbox":true}"#)
                    let tableDataset = TableDataset(json: json)

                    let fileURL = makeTemporaryFile(name: "table-dataset")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: tableDataset,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedTableDataset = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! TableDataset

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
