//
//  Submission.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class Submission: JSONSerializable {
    typealias IdType = Int

    var id: IdType = 0
    var status: String?
    var hint: String?
    var feedback: SubmissionFeedback?
    var time = Date()
    var reply: Reply?
    var attemptID: Attempt.IdType = 0
    var attempt: Attempt?

    var isCorrect: Bool { self.status == "correct" }

    var json: JSON {
        [
            JSONKey.attempt.rawValue: attemptID,
            JSONKey.reply.rawValue: reply?.dictValue ?? ""
        ]
    }

    init(json: JSON, stepName: String) {
        self.update(json: json)
        self.reply = nil
        self.reply = self.getReplyFromJSON(json[JSONKey.reply.rawValue], stepName: stepName)
    }

    init(attempt: Int, reply: Reply) {
        self.attemptID = attempt
        self.reply = reply
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.status = json[JSONKey.status.rawValue].string
        self.hint = json[JSONKey.hint.rawValue].string
        self.feedback = self.getFeedbackFromJSON(json[JSONKey.feedback.rawValue])
        self.attemptID = json[JSONKey.attempt.rawValue].intValue
        self.time = Parser.shared.dateFromTimedateJSON(json[JSONKey.time.rawValue]) ?? Date()
    }

    func initReply(json: JSON, stepName: String) {
        self.reply = self.getReplyFromJSON(json, stepName: stepName)
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json[JSONKey.id.rawValue].int
    }

    private func getReplyFromJSON(_ json: JSON, stepName: String) -> Reply? {
        switch stepName {
        case "choice":
            return ChoiceReply(json: json)
        case "string":
            return TextReply(json: json)
        case "number":
            return NumberReply(json: json)
        case "free-answer":
            return FreeAnswerReply(json: json)
        case "math":
            return MathReply(json: json)
        case "sorting":
            return SortingReply(json: json)
        case "matching":
            return MatchingReply(json: json)
        case "code":
            return CodeReply(json: json)
        case "sql":
            return SQLReply(json: json)
        default:
            return nil
        }
    }

    private func getFeedbackFromJSON(_ json: JSON) -> SubmissionFeedback? {
        if let _ = json[JSONKey.optionsFeedback.rawValue].arrayObject as? [String] {
            return ChoiceSubmissionFeedback(json: json)
        }
        if let _ = json.string {
            return StringSubmissionFeedback(json: json)
        }
        return nil
    }

    // MARK: Types

    enum JSONKey: String {
        case id
        case status
        case hint
        case attempt
        case reply
        case feedback
        case time
        case optionsFeedback = "options_feedback"
    }
}

extension Submission: UniqueIdentifiable {
    var uniqueIdentifier: UniqueIdentifierType {
        "\(self.id)"
    }
}

extension Submission: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        Submission(id: \(id), \
        status: \(status ?? "nil"), \
        hint: \(hint ?? "nil"), \
        feedback: \(feedback ??? "nil"), \
        reply: \(reply ??? "nil"), \
        attemptID: \(attemptID), \
        attempt: \(attempt ??? "nil"))
        """
    }
}
