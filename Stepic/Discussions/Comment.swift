//
//  Comment.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

enum UserRole: String {
    case student
    case teacher
    case staff
}

final class Comment: JSONSerializable {
    var id: Int = -1
    var parentID: Comment.IdType?
    var userID: User.IdType = 0
    var userRole: UserRole = .student
    var time = Date()
    var lastTime = Date()
    var text: String = ""
    var replyCount: Int = 0
    var isDeleted: Bool = false
    var targetStepID: Int = 0
    var repliesIDs: [Int] = []
    var isPinned: Bool = false
    var voteID: String = ""
    var epicCount: Int = 0
    var abuseCount: Int = 0
    var actions: [Action] = []

    var userInfo: UserInfo!
    var vote: Vote!

    var json: JSON {
        var dict: JSON = [
            JSONKey.target.rawValue: self.targetStepID,
            JSONKey.text.rawValue: self.text
        ]

        if let parentID = self.parentID {
            try? dict.merge(
                with: [
                    JSONKey.parent.rawValue: parentID
                ]
            )
        }

        return dict
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    init(parent: Int? = nil, target: Int, text: String) {
        self.parentID = parent
        self.targetStepID = target
        self.text = text
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.parentID = json[JSONKey.parent.rawValue].int
        self.userID = json[JSONKey.user.rawValue].intValue
        self.userRole = UserRole(rawValue: json[JSONKey.userRole.rawValue].stringValue) ?? .student
        self.time = Parser.shared.dateFromTimedateJSON(json[JSONKey.time.rawValue]).require()
        self.lastTime = Parser.shared.dateFromTimedateJSON(json[JSONKey.lastTime.rawValue]).require()
        self.text = json[JSONKey.text.rawValue].stringValue
        self.replyCount = json[JSONKey.replyCount.rawValue].intValue
        self.isDeleted = json[JSONKey.isDeleted.rawValue].boolValue
        self.targetStepID = json[JSONKey.target.rawValue].intValue
        self.repliesIDs = json[JSONKey.replies.rawValue].arrayValue.compactMap { $0.int }
        self.isPinned = json[JSONKey.isPinned.rawValue].boolValue
        self.voteID = json[JSONKey.vote.rawValue].stringValue
        self.epicCount = json[JSONKey.epicCount.rawValue].intValue
        self.abuseCount = json[JSONKey.abuseCount.rawValue].intValue

        self.actions.removeAll(keepingCapacity: true)
        for (actionKey, value) in json[JSONKey.actions.rawValue].dictionaryValue {
            guard let action = Action(rawValue: actionKey) else {
                continue
            }

            if value.boolValue {
                self.actions.append(action)
            }
        }
    }

    enum Action: String {
        case delete
        case pin
        case report
        case vote
        case edit
    }

    enum JSONKey: String {
        case id
        case parent
        case user
        case userRole = "user_role"
        case time
        case lastTime = "last_time"
        case text
        case replyCount = "reply_count"
        case isDeleted = "is_deleted"
        case target
        case replies
        case isPinned = "is_pinned"
        case vote
        case epicCount = "epic_count"
        case abuseCount = "abuse_count"
        case actions
        case users
        case votes
    }
}
