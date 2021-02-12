import Nimble
import Quick
import SwiftyJSON

@testable import Stepic

class SubmissionSpec: QuickSpec {
    override func spec() {
        describe("Submission") {
            describe("JSON pasing") {
                it("successfully parses with choices reply") {
                    let json = JSON(parseJSON: ReplyType.choices.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.choice.rawValue)

                    expect(submission.id) == 164530189
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == ""
                    expect(submission.reply as? ChoiceReply) == ChoiceReply(choices: [false, true, false, false])
                    expect(submission.attemptID) == 155142602
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }

                it("successfully parses with text reply") {
                    let json = JSON(parseJSON: ReplyType.text.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.string.rawValue)

                    expect(submission.id) == 163700855
                    expect(submission.statusString) == "wrong"
                    expect(submission.hint) == ""
                    expect(submission.reply as? TextReply) == TextReply(text: "text")
                    expect(submission.attemptID) == 145802794
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }

                it("successfully parses with number reply") {
                    let json = JSON(parseJSON: ReplyType.number.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.number.rawValue)

                    expect(submission.id) == 155034240
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == "Optional feedback on correct submission"
                    expect(submission.reply as? NumberReply) == NumberReply(number: "25.5")
                    expect(submission.attemptID) == 145800697
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(
                        string: "Optional feedback on correct submission"
                    )
                }

                it("successfully parses with free-answer reply") {
                    let json = JSON(parseJSON: ReplyType.freeAnswer.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.freeAnswer.rawValue)

                    expect(submission.id) == 155035432
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == ""
                    expect(submission.reply as? FreeAnswerReply) == FreeAnswerReply(text: "test")
                    expect(submission.attemptID) == 145801887
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }

                it("successfully parses with math reply") {
                    let json = JSON(parseJSON: ReplyType.math.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.math.rawValue)

                    expect(submission.id) == 163701768
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == ""
                    expect(submission.reply as? MathReply) == MathReply(formula: "2*x+y/z")
                    expect(submission.attemptID) == 145803773
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }

                it("successfully parses with sorting reply") {
                    let json = JSON(parseJSON: ReplyType.sorting.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.sorting.rawValue)

                    expect(submission.id) == 163701921
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == ""
                    expect(submission.reply as? SortingReply) == SortingReply(ordering: [0, 1, 2])
                    expect(submission.attemptID) == 145804003
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }

                it("successfully parses with matching reply") {
                    let json = JSON(parseJSON: ReplyType.matching.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.matching.rawValue)

                    expect(submission.id) == 163702173
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == ""
                    expect(submission.reply as? MatchingReply) == MatchingReply(ordering: [2, 1, 0])
                    expect(submission.attemptID) == 145805676
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }

                it("successfully parses with code reply") {
                    let json = JSON(parseJSON: ReplyType.code.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.code.rawValue)

                    expect(submission.id) == 163968205
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == ""
                    expect(submission.reply as? CodeReply) == CodeReply(
                        code: "def main():\n    \n    a, b = map(int, input().split())\n    res = a + b\n    print(res)\n\n\nif __name__ == \"__main__\":\n    main()",
                        language: .python
                    )
                    expect(submission.attemptID) == 129167799
                    expect(submission.attempt).to(beNil())

                    expect(submission.feedback).to(beNil())
                }

                it("successfully parses with SQL reply") {
                    let json = JSON(parseJSON: ReplyType.sql.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.sql.rawValue)

                    expect(submission.id) == 163702543
                    expect(submission.statusString) == "correct"
                    expect(submission.hint) == "Affected rows: 1"
                    expect(submission.reply as? SQLReply) == SQLReply(code: "INSERT INTO users (name) VALUES ('Fluttershy');\n")
                    expect(submission.attemptID) == 145794719
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "Affected rows: 1")
                }

                it("successfully parses with fill blanks reply") {
                    let json = JSON(parseJSON: ReplyType.fillBlanks.submissionJSONString)
                    let submission = Submission(json: json, stepBlockName: BlockType.fillBlanks.rawValue)

                    expect(submission.id) == 276062563
                    expect(submission.statusString) == "wrong"
                    expect(submission.hint) == ""
                    expect(submission.reply as? FillBlanksReply) == FillBlanksReply(blanks: ["4", "5"])
                    expect(submission.attemptID) == 264183878
                    expect(submission.attempt).to(beNil())
                    expect(submission.feedback) == StringSubmissionFeedback(string: "")
                }
            }
        }
    }

    enum ReplyType {
        case choices
        case text
        case number
        case freeAnswer
        case math
        case sorting
        case matching
        case code
        case sql
        case fillBlanks

        var submissionJSONString: String {
            switch self {
            case .choices:
                return """
                {
                  "id": 164530189,
                  "status": "correct",
                  "score": 1,
                  "hint": "",
                  "feedback": "",
                  "time": "2020-01-30T10:13:15Z",
                  "reply": {
                    "choices": [
                      false,
                      true,
                      false,
                      false
                    ]
                  },
                  "reply_url": null,
                  "attempt": 155142602,
                  "session": null,
                  "eta": 0
                }
                """
            case .text:
                return """
                {
                  "id": 163700855,
                  "status": "wrong",
                  "score": 0,
                  "hint": "",
                  "feedback": "",
                  "time": "2020-01-27T09:54:55Z",
                  "reply": {
                    "text": "text",
                    "files": []
                  },
                  "reply_url": null,
                  "attempt": 145802794,
                  "session": null,
                  "eta": 0
                }
                """
            case .number:
                return """
                {
                  "id": 155034240,
                  "status": "correct",
                  "score": 1,
                  "hint": "Optional feedback on correct submission",
                  "feedback": "Optional feedback on correct submission",
                  "time": "2019-12-20T17:02:33Z",
                  "reply": {
                    "number": "25.5"
                  },
                  "reply_url": null,
                  "attempt": 145800697,
                  "session": null,
                  "eta": 0
                }
                """
            case .freeAnswer:
                return """
                {
                  "id": 155035432,
                  "status": "correct",
                  "score": 1,
                  "hint": "",
                  "feedback": "",
                  "time": "2019-12-20T17:07:35Z",
                  "reply": {
                    "text": "test",
                    "attachments": []
                  },
                  "reply_url": null,
                  "attempt": 145801887,
                  "session": null,
                  "eta": 0
                }
                """
            case .math:
                return """
                {
                  "id": 163701768,
                  "status": "correct",
                  "score": 1,
                  "hint": "",
                  "feedback": "",
                  "time": "2020-01-27T09:58:06Z",
                  "reply": {
                    "formula": "2*x+y/z"
                  },
                  "reply_url": null,
                  "attempt": 145803773,
                  "session": null,
                  "eta": 0
                }
                """
            case .sorting:
                return """
                {
                  "id": 163701921,
                  "status": "correct",
                  "score": 1,
                  "hint": "",
                  "feedback": "",
                  "time": "2020-01-27T09:58:38Z",
                  "reply": {
                    "ordering": [
                      0,
                      1,
                      2
                    ]
                  },
                  "reply_url": null,
                  "attempt": 145804003,
                  "session": null,
                  "eta": 0
                }
                """
            case .matching:
                return """
                {
                  "id": 163702173,
                  "status": "correct",
                  "score": 1,
                  "hint": "",
                  "feedback": "",
                  "time": "2020-01-27T09:59:29Z",
                  "reply": {
                    "ordering": [
                      2,
                      1,
                      0
                    ]
                  },
                  "reply_url": null,
                  "attempt": 145805676,
                  "session": null,
                  "eta": 0
                }
                """
            case .code:
                return #"{"id": 163968205, "status": "correct", "score": 1.0, "hint": "", "feedback": {"message": "", "code_style": {"errors": [{"code": "W293", "text": "blank line contains whitespace", "line": "    ", "line_number": 1, "column_number": 0}, {"code": "W292", "text": "no newline at end of file", "line": "    main()", "line_number": 8, "column_number": 10}]}}, "time": "2020-01-28T08:27:44Z", "reply": {"code": "def main():\n    \n    a, b = map(int, input().split())\n    res = a + b\n    print(res)\n\n\nif __name__ == \"__main__\":\n    main()", "language": "python3"}, "reply_url": null, "attempt": 129167799, "session": null, "eta": 0}"#
            case .sql:
                return #"{"id": 163702543, "status": "correct", "score": 1.0, "hint": "Affected rows: 1", "feedback": "Affected rows: 1", "time": "2020-01-27T10:00:50Z", "reply": {"solve_sql": "INSERT INTO users (name) VALUES ('Fluttershy');\n"}, "reply_url": null, "attempt": 145794719, "session": null, "eta": 0}"#
            case .fillBlanks:
                return """
                {
                  "id": 276062563,
                  "status": "wrong",
                  "score": 0.0,
                  "hint": "",
                  "feedback": "",
                  "time": "2020-08-17T04:05:45Z",
                  "reply": {
                  "blanks": [
                      "4",
                      "5"
                    ]
                  },
                  "reply_url": null,
                  "attempt": 264183878,
                  "session": null,
                  "eta": 0
                }
                """
            }
        }
    }
}
