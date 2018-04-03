//
//  Submission.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Submission: JSONSerializable {

    typealias IdType = Int

    var id: Int = 0
    var status: String?
    var reply: Reply?
    var attempt: Int = 0
    var hint: String?

    init(json: JSON, stepName: String) {
        id = json["id"].intValue
        status = json["status"].string
        attempt = json["attempt"].intValue
        hint = json["hint"].string
        reply = nil
        reply = getReplyFromJSON(json["reply"], stepName: stepName)
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
    }

    func initReply(json: JSON, stepName: String) {
        reply = getReplyFromJSON(json, stepName: stepName)
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].int
    }

    var json: JSON {
        return [
            "attempt": attempt,
            "reply": reply?.dictValue ?? ""
        ]
    }

    fileprivate func getReplyFromJSON(_ json: JSON, stepName: String) -> Reply? {
        switch stepName {
        case "choice" : return ChoiceReply(json: json)
        case "string" : return TextReply(json: json)
        case "number": return NumberReply(json: json)
        case "free-answer": return FreeAnswerReply(json: json)
        case "math": return MathReply(json: json)
        case "sorting": return SortingReply(json: json)
        case "matching": return MatchingReply(json: json)
        case "fill-blanks": return FillBlanksReply(json: json)
        case "code": return CodeReply(json: json)
        case "sql": return SQLReply(json: json)
        default: return nil
        }
    }

}
