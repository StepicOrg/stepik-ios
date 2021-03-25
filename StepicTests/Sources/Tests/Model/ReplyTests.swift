@testable
import Stepic

import Nimble
import Quick
import SwiftyJSON

class ReplySpec: QuickSpec {
    override func spec() {
        describe("Reply") {
            describe("NSSecureCoding") {
                func makeTemporaryFile(name: String) -> URL {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return URL(fileURLWithPath: temporaryDirectoryPath.appendingPathComponent(name))
                }

                it("choice reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"choices": [false, true, false, false]}"#)
                    let choiceReply = ChoiceReply(json: json)

                    let fileURL = makeTemporaryFile(name: "choice-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: choiceReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedChoiceReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! ChoiceReply

                    // Then
                    expect(unarchivedChoiceReply) == choiceReply
                    expect(unarchivedChoiceReply.choices) == [false, true, false, false]
                }

                it("text reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"text": "test text", "files": []}"#)
                    let textReply = TextReply(json: json)

                    let fileURL = makeTemporaryFile(name: "text-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: textReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedTextReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! TextReply

                    // Then
                    expect(unarchivedTextReply) == textReply
                    expect(unarchivedTextReply.text) == "test text"
                }

                it("number reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"number": "25"}"#)
                    let numberReply = NumberReply(json: json)

                    let fileURL = makeTemporaryFile(name: "number-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: numberReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedNumberReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! NumberReply

                    // Then
                    expect(unarchivedNumberReply) == numberReply
                    expect(unarchivedNumberReply.number) == "25"
                }

                it("free answer reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"text": "test", "attachments": []}"#)
                    let freeAnswerReply = FreeAnswerReply(json: json)

                    let fileURL = makeTemporaryFile(name: "free-answer-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: freeAnswerReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedFreeAnswerReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! FreeAnswerReply

                    // Then
                    expect(unarchivedFreeAnswerReply) == freeAnswerReply
                    expect(unarchivedFreeAnswerReply.text) == "test"
                }

                it("math reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"formula": "2*x+y/z"}"#)
                    let mathReply = MathReply(json: json)

                    let fileURL = makeTemporaryFile(name: "math-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: mathReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedMathReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! MathReply

                    // Then
                    expect(unarchivedMathReply) == mathReply
                    expect(unarchivedMathReply.formula) == "2*x+y/z"
                }

                it("sorting reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"ordering": [2, 0, 1]}"#)
                    let sortingReply = SortingReply(json: json)

                    let fileURL = makeTemporaryFile(name: "sorting-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: sortingReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedSortingReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! SortingReply

                    // Then
                    expect(unarchivedSortingReply) == sortingReply
                    expect(unarchivedSortingReply.ordering) == [2, 0, 1]
                }

                it("matching reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"ordering": [1, 2, 0]}"#)
                    let matchingReply = MatchingReply(json: json)

                    let fileURL = makeTemporaryFile(name: "matching-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: matchingReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedMatchingReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! MatchingReply

                    // Then
                    expect(unarchivedMatchingReply) == matchingReply
                    expect(unarchivedMatchingReply.ordering) == [1, 2, 0]
                }

                it("code reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"language": "python3", "code": "def main():\n    pass"}"#)
                    let codeReply = CodeReply(json: json)

                    let fileURL = makeTemporaryFile(name: "code-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: codeReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedCodeReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! CodeReply

                    // Then
                    expect(unarchivedCodeReply) == codeReply
                    expect(unarchivedCodeReply.languageName) == "python3"
                    expect(unarchivedCodeReply.code) == "def main():\n    pass"
                }

                it("sql reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"solve_sql": "INSERT INTO users (name) VALUES ('Fluttershy');\n"}"#)
                    let sqlReply = SQLReply(json: json)

                    let fileURL = makeTemporaryFile(name: "sql-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: sqlReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedSQLReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! SQLReply

                    // Then
                    expect(unarchivedSQLReply) == sqlReply
                    expect(unarchivedSQLReply.code) == "INSERT INTO users (name) VALUES ('Fluttershy');\n"
                }

                it("fill blanks reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"blanks": ["4", "5"]}"#)
                    let fillBlanksReply = FillBlanksReply(json: json)

                    let fileURL = makeTemporaryFile(name: "fill-blanks-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: fillBlanksReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedFillBlanksReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! FillBlanksReply

                    // Then
                    expect(unarchivedFillBlanksReply) == fillBlanksReply
                    expect(unarchivedFillBlanksReply.blanks) == ["4", "5"]
                }

                it("table reply encoded and decoded") {
                    // Given
                    let jsonString = #"""
{
  "choices": [
    {
      "name_row": "United States",
      "columns": [
        {
          "name": "New York",
          "answer": false
        },
        {
          "name": "Moscow",
          "answer": false
        },
        {
          "name": "Minsk",
          "answer": false
        },
        {
          "name": "Washington",
          "answer": true
        },
        {
          "name": "London",
          "answer": false
        }
      ]
    },
    {
      "name_row": "England",
      "columns": [
        {
          "name": "New York",
          "answer": false
        },
        {
          "name": "Moscow",
          "answer": false
        },
        {
          "name": "Minsk",
          "answer": false
        },
        {
          "name": "Washington",
          "answer": false
        },
        {
          "name": "London",
          "answer": true
        }
      ]
    },
    {
      "name_row": "Belarus",
      "columns": [
        {
          "name": "New York",
          "answer": false
        },
        {
          "name": "Moscow",
          "answer": false
        },
        {
          "name": "Minsk",
          "answer": true
        },
        {
          "name": "Washington",
          "answer": false
        },
        {
          "name": "London",
          "answer": false
        }
      ]
    },
    {
      "name_row": "Russia",
      "columns": [
        {
          "name": "New York",
          "answer": false
        },
        {
          "name": "Moscow",
          "answer": true
        },
        {
          "name": "Minsk",
          "answer": false
        },
        {
          "name": "Washington",
          "answer": false
        },
        {
          "name": "London",
          "answer": false
        }
      ]
    }
  ]
}
"""#
                    let json = JSON(parseJSON: jsonString)
                    let tableReply = TableReply(json: json)

                    let rows = ["United States", "England", "Belarus", "Russia"]
                    let columns = ["New York", "Moscow", "Minsk", "Washington", "London"]
                    let answers = [
                        "United States": "Washington",
                        "England": "London",
                        "Belarus": "Minsk",
                        "Russia": "Moscow"
                    ]

                    var choices: [TableReplyChoice] = []

                    for row in rows {
                        let choice = TableReplyChoice(
                            rowName: row,
                            columns: columns.map { column in
                                .init(name: column, answer: answers[row] == column)
                            }
                        )
                        choices.append(choice)
                    }

                    let fileURL = makeTemporaryFile(name: "table-reply")

                    // When
                    let archivedData = try! NSKeyedArchiver.archivedData(
                        withRootObject: tableReply,
                        requiringSecureCoding: true
                    )
                    try! archivedData.write(to: fileURL)

                    let unarchivedData = try! Data(contentsOf: fileURL)
                    let unarchivedTableReply = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                        unarchivedData
                    ) as! TableReply

                    // Then
                    expect(unarchivedTableReply) == tableReply
                    expect(unarchivedTableReply.choices) == choices
                }
            }
        }
    }
}
