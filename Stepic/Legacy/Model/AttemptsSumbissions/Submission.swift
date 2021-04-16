//
//  Submission.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class Submission: JSONSerializable, Hashable {
    typealias IdType = Int

    var id: IdType = 0
    var statusString: String?
    var score: Float = 0
    var hint: String?
    var feedback: SubmissionFeedback?
    var time = Date()
    var reply: Reply?
    var attemptID: Attempt.IdType = 0
    var attempt: Attempt?
    var sessionID: Int?
    var session: ReviewSessionDataPlainObject?
    var isLocal = false

    var status: SubmissionStatus? {
        get {
            if let stringValue = self.statusString {
                return SubmissionStatus(rawValue: stringValue)
            }
            return nil
        }
        set {
            self.statusString = newValue?.rawValue
        }
    }

    var isCorrect: Bool { self.status == .correct }

    var isPartiallyCorrect: Bool { self.isCorrect && self.score < 1.0 }

    var json: JSON {
        [
            JSONKey.attempt.rawValue: attemptID,
            JSONKey.reply.rawValue: reply?.dictValue ?? ""
        ]
    }

    init(
        id: IdType,
        status: SubmissionStatus? = nil,
        score: Float? = 0,
        hint: String? = nil,
        feedback: SubmissionFeedback? = nil,
        time: Date = Date(),
        reply: Reply? = nil,
        attemptID: Attempt.IdType,
        attempt: Attempt? = nil,
        sessionID: Int? = nil,
        isLocal: Bool = false
    ) {
        self.id = id
        self.statusString = status?.rawValue
        self.score = score ?? 0
        self.hint = hint
        self.feedback = feedback
        self.time = time
        self.reply = reply
        self.attemptID = attemptID
        self.attempt = attempt
        self.sessionID = sessionID
        self.isLocal = isLocal
    }

    init(json: JSON, stepBlockName: String) {
        self.update(json: json)
        self.reply = nil
        self.reply = self.getReplyFromJSON(json[JSONKey.reply.rawValue], stepBlockName: stepBlockName)
    }

    init(attempt: Int, reply: Reply, status: SubmissionStatus? = nil) {
        self.attemptID = attempt
        self.reply = reply
        self.statusString = status?.rawValue
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    convenience init(submission: Submission?) {
        self.init(
            id: submission?.id ?? 0,
            status: submission?.status,
            score: submission?.score,
            hint: submission?.hint,
            feedback: submission?.feedback,
            time: submission?.time ?? Date(),
            reply: submission?.reply,
            attemptID: submission?.attemptID ?? 0,
            attempt: submission?.attempt,
            sessionID: submission?.sessionID
        )
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.statusString = json[JSONKey.status.rawValue].string
        self.score = json[JSONKey.score.rawValue].floatValue
        self.hint = json[JSONKey.hint.rawValue].string
        self.feedback = self.getFeedbackFromJSON(json[JSONKey.feedback.rawValue])
        self.attemptID = json[JSONKey.attempt.rawValue].intValue
        self.sessionID = json[JSONKey.session.rawValue].int
        self.time = Parser.dateFromTimedateJSON(json[JSONKey.time.rawValue]) ?? Date()
    }

    func initReply(json: JSON, stepBlockName: String) {
        self.reply = self.getReplyFromJSON(json, stepBlockName: stepBlockName)
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json[JSONKey.id.rawValue].int
    }

    // MARK: Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.statusString)
        hasher.combine(self.score)
        hasher.combine(self.hint)
        hasher.combine(self.feedback)
        hasher.combine(self.time)
        hasher.combine(self.reply)
        hasher.combine(self.attemptID)
        hasher.combine(self.attempt)
        hasher.combine(self.sessionID)
        hasher.combine(self.isLocal)
    }

    static func == (lhs: Submission, rhs: Submission) -> Bool {
        if lhs === rhs { return true }
        if type(of: lhs) != type(of: rhs) { return false }

        if lhs.id != rhs.id { return false }
        if lhs.statusString != rhs.statusString { return false }
        if lhs.score != rhs.score { return false }
        if lhs.hint != rhs.hint { return false }
        if lhs.time != rhs.time { return false }
        if lhs.attemptID != rhs.attemptID { return false }
        if lhs.attempt != rhs.attempt { return false }
        if lhs.sessionID != rhs.sessionID { return false }

        if let lhsFeedback = lhs.feedback {
            if !lhsFeedback.isEqual(rhs.feedback) { return false }
        } else if rhs.feedback != nil {
            return false
        }

        if let lhsReply = lhs.reply {
            if !lhsReply.isEqual(rhs.reply) { return false }
        } else if rhs.reply != nil {
            return false
        }

        return true
    }

    // MARK: Private API

    private func getReplyFromJSON(_ json: JSON, stepBlockName: String) -> Reply? {
        guard let blockType = BlockType(rawValue: stepBlockName) else {
            return nil
        }

        switch blockType {
        case .choice:
            return ChoiceReply(json: json)
        case .string:
            return TextReply(json: json)
        case .number:
            return NumberReply(json: json)
        case .fillBlanks:
            return FillBlanksReply(json: json)
        case .freeAnswer:
            return FreeAnswerReply(json: json)
        case .math:
            return MathReply(json: json)
        case .sorting:
            return SortingReply(json: json)
        case .matching:
            return MatchingReply(json: json)
        case .code:
            return CodeReply(json: json)
        case .sql:
            return SQLReply(json: json)
        case .table:
            return TableReply(json: json)
        default:
            return nil
        }
    }

    private func getFeedbackFromJSON(_ json: JSON) -> SubmissionFeedback? {
        if let _ = json[JSONKey.optionsFeedback.rawValue].arrayObject as? [String] {
            return ChoiceSubmissionFeedback(json: json)
        }
        if let _ = json[JSONKey.blanksFeedback.rawValue].arrayObject as? [Bool] {
            return FillBlanksFeedback(json: json)
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
        case score
        case hint
        case attempt
        case session
        case reply
        case feedback
        case time
        case optionsFeedback = "options_feedback"
        case blanksFeedback = "blanks_feedback"
    }
}

extension Submission: UniqueIdentifiable {
    var uniqueIdentifier: UniqueIdentifierType { "\(self.id)" }
}

extension Submission: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        Submission(id: \(id), \
        status: \(statusString ?? "nil"), \
        score: \(score), \
        hint: \(hint ?? "nil"), \
        feedback: \(feedback ??? "nil"), \
        reply: \(reply ??? "nil"), \
        attemptID: \(attemptID), \
        attempt: \(attempt ??? "nil"), \
        sessionID: \(sessionID ??? "nil"))
        """
    }
}
