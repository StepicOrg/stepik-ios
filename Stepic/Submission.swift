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

    var id: Int = 0
    var status: String?
    var reply: Reply?
    var attempt: Int = 0
    var hint: String?
    var feedback: SubmissionFeedback?

    init(json: JSON, stepName: String) {
        id = json["id"].intValue
        status = json["status"].string
        attempt = json["attempt"].intValue
        hint = json["hint"].string
        reply = nil
        reply = getReplyFromJSON(json["reply"], stepName: stepName)
        feedback = SubmissionFeedback(json: json["feedback"])
    }

    init(attempt: Int, reply: Reply) {
        self.attempt = attempt
        self.reply = reply
    }

    required init(json: JSON) {
        update(json: json)
    }

    func update(json: JSON) {
        id = json["id"].intValue
        status = json["status"].string
        attempt = json["attempt"].intValue
        hint = json["hint"].string
        feedback = SubmissionFeedback(json: json["feedback"])
    }

    func initReply(json: JSON, stepName: String) {
        reply = getReplyFromJSON(json, stepName: stepName)
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json["id"].int
    }

    var json: JSON {
        [
            "attempt": attempt,
            "reply": reply?.dictValue ?? ""
        ]
    }

    private func getReplyFromJSON(_ json: JSON, stepName: String) -> Reply? {
        switch stepName {
        case "choice" : return ChoiceReply(json: json)
        case "string" : return TextReply(json: json)
        case "number": return NumberReply(json: json)
        case "free-answer": return FreeAnswerReply(json: json)
        case "math": return MathReply(json: json)
        case "sorting": return SortingReply(json: json)
        case "matching": return MatchingReply(json: json)
        case "code": return CodeReply(json: json)
        case "sql": return SQLReply(json: json)
        default: return nil
        }
    }
}

enum SubmissionFeedback {
    case options(_ choices: [String])

    init?(json: JSON) {
        if let options = json["options_feedback"].arrayObject as? [String] {
            self = .options(options)
            return
        }
        return nil
    }
}
