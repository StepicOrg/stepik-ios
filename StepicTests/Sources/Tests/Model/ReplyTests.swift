import Nimble
import Quick
import SwiftyJSON

@testable import Stepic

class ReplySpec: QuickSpec {
    override func spec() {
        describe("Reply") {
            describe("NSCoding") {
                func makeTemporaryPath(name: String) -> String {
                    let temporaryDirectoryPath = NSTemporaryDirectory() as NSString
                    return temporaryDirectoryPath.appendingPathComponent(name)
                }

                it("choice reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"choices": [false, true, false, false]}"#)
                    let choiceReply = ChoiceReply(json: json)

                    let path = makeTemporaryPath(name: "choice-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(choiceReply, toFile: path)

                    let unarchivedChoiceReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! ChoiceReply

                    // Then
                    expect(unarchivedChoiceReply) == choiceReply
                    expect(unarchivedChoiceReply.choices) == [false, true, false, false]
                }

                it("text reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"text": "test text", "files": []}"#)
                    let textReply = TextReply(json: json)

                    let path = makeTemporaryPath(name: "text-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(textReply, toFile: path)

                    let unarchivedTextReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! TextReply

                    // Then
                    expect(unarchivedTextReply) == textReply
                    expect(unarchivedTextReply.text) == "test text"
                }

                it("number reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"number": "25"}"#)
                    let numberReply = NumberReply(json: json)

                    let path = makeTemporaryPath(name: "number-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(numberReply, toFile: path)

                    let unarchivedNumberReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! NumberReply

                    // Then
                    expect(unarchivedNumberReply) == numberReply
                    expect(unarchivedNumberReply.number) == "25"
                }

                it("free answer reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"text": "test", "attachments": []}"#)
                    let freeAnswerReply = FreeAnswerReply(json: json)

                    let path = makeTemporaryPath(name: "free-answer-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(freeAnswerReply, toFile: path)

                    let unarchivedFreeAnswerReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! FreeAnswerReply

                    // Then
                    expect(unarchivedFreeAnswerReply) == freeAnswerReply
                    expect(unarchivedFreeAnswerReply.text) == "test"
                }

                it("math reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"formula": "2*x+y/z"}"#)
                    let mathReply = MathReply(json: json)

                    let path = makeTemporaryPath(name: "math-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(mathReply, toFile: path)

                    let unarchivedMathReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! MathReply

                    // Then
                    expect(unarchivedMathReply) == mathReply
                    expect(unarchivedMathReply.formula) == "2*x+y/z"
                }

                it("sorting reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"ordering": [2, 0, 1]}"#)
                    let sortingReply = SortingReply(json: json)

                    let path = makeTemporaryPath(name: "sorting-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(sortingReply, toFile: path)

                    let unarchivedSortingReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SortingReply

                    // Then
                    expect(unarchivedSortingReply) == sortingReply
                    expect(unarchivedSortingReply.ordering) == [2, 0, 1]
                }

                it("matching reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"ordering": [1, 2, 0]}"#)
                    let matchingReply = MatchingReply(json: json)

                    let path = makeTemporaryPath(name: "matching-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(matchingReply, toFile: path)

                    let unarchivedMatchingReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! MatchingReply

                    // Then
                    expect(unarchivedMatchingReply) == matchingReply
                    expect(unarchivedMatchingReply.ordering) == [1, 2, 0]
                }

                it("code reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"language": "python3", "code": "def main():\n    pass"}"#)
                    let codeReply = CodeReply(json: json)

                    let path = makeTemporaryPath(name: "code-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(codeReply, toFile: path)

                    let unarchivedCodeReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! CodeReply

                    // Then
                    expect(unarchivedCodeReply) == codeReply
                    expect(unarchivedCodeReply.languageName) == "python3"
                    expect(unarchivedCodeReply.code) == "def main():\n    pass"
                }

                it("sql reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"solve_sql": "INSERT INTO users (name) VALUES ('Fluttershy');\n"}"#)
                    let sqlReply = SQLReply(json: json)

                    let path = makeTemporaryPath(name: "sql-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(sqlReply, toFile: path)

                    let unarchivedSQLReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SQLReply

                    // Then
                    expect(unarchivedSQLReply) == sqlReply
                    expect(unarchivedSQLReply.code) == "INSERT INTO users (name) VALUES ('Fluttershy');\n"
                }

                it("fill blanks reply encoded and decoded") {
                    // Given
                    let json = JSON(parseJSON: #"{"blanks": ["4", "5"]}"#)
                    let fillBlanksReply = FillBlanksReply(json: json)

                    let path = makeTemporaryPath(name: "fill-blanks-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(fillBlanksReply, toFile: path)

                    let unarchivedReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! FillBlanksReply

                    // Then
                    expect(unarchivedReply) == fillBlanksReply
                    expect(unarchivedReply.blanks) == ["4", "5"]
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

                    let path = makeTemporaryPath(name: "table-reply")

                    // When
                    NSKeyedArchiver.archiveRootObject(tableReply, toFile: path)

                    let unarchivedTableReply = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! TableReply

                    // Then
                    expect(unarchivedTableReply) == tableReply
                    expect(unarchivedTableReply.choices) == choices
                }
            }
        }
    }
}
