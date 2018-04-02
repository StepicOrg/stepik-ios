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
    case Student = "student", Teacher = "teacher", Staff = "staff"
}

/*
 Comment model, without voting
 */
class Comment: JSONSerializable {

    typealias IdType = Int

    var id: Int = 0
    var parentId: Int?
    var userId: Int = 0
    var userRole: UserRole = .Student
    var time: Date = Date()
    var lastTime: Date = Date()
    var text: String = ""
    var replyCount: Int = 0
    var isDeleted: Bool = false
    var targetStepId: Int = 0
    var repliesIds: [Int] = []
    var isPinned: Bool = false
    var voteId: String = ""
    var epicCount: Int = 0
    var abuseCount: Int = 0

    //TODO: Check those "!" marks, they look suspicious
    var userInfo: UserInfo!
    var vote: Vote!

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        parentId = json["parent"].int
        userId = json["user"].intValue
        userRole = UserRole(rawValue: json["user_role"].stringValue) ?? .Student
        time = Parser.sharedParser.dateFromTimedateJSON(json["time"])!
        lastTime = Parser.sharedParser.dateFromTimedateJSON(json["last_time"])!
        text = json["text"].stringValue
        replyCount = json["reply_count"].intValue
        isDeleted = json["is_deleted"].boolValue
        targetStepId = json["target"].intValue
        repliesIds = json["replies"].arrayValue.flatMap {
            $0.int
        }
        isPinned = json["is_pinned"].boolValue
        voteId = json["vote"].stringValue
        epicCount = json["epic_count"].intValue
        abuseCount = json["abuse_count"].intValue
    }

    required init(json: JSON) {
        id = json["id"].intValue
        parentId = json["parent"].int
        userId = json["user"].intValue
        userRole = UserRole(rawValue: json["user_role"].stringValue) ?? .Student
        time = Parser.sharedParser.dateFromTimedateJSON(json["time"])!
        lastTime = Parser.sharedParser.dateFromTimedateJSON(json["last_time"])!
        text = json["text"].stringValue
        replyCount = json["reply_count"].intValue
        isDeleted = json["is_deleted"].boolValue
        targetStepId = json["target"].intValue
        repliesIds = json["replies"].arrayValue.flatMap {
            $0.int
        }
        isPinned = json["is_pinned"].boolValue
        voteId = json["vote"].stringValue
        epicCount = json["epic_count"].intValue
        abuseCount = json["abuse_count"].intValue
    }

    func update(json: JSON) {
        initialize(json)
    }

    init(parent: Int? = nil, target: Int, text: String) {
        self.parentId = parent
        self.targetStepId = target
        self.text = text
    }

    var json: JSON {
        var dict: JSON = [
            "target": targetStepId,
            "text": text
        ]
        if let parent = parentId {
            try! dict.merge(with: ["parent": parent])
        }

        return dict
    }
}
