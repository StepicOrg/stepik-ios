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
class Comment: JSONInitializable {
    var id: Int
    var parentId: Int?
    var userId: Int
    var userRole: UserRole
    var time: NSDate
    var lastTime: NSDate
    var text: String
    var replyCount: Int
    var isDeleted: Bool
    var targetStepId: Int
    var repliesIds : [Int]
    var isPinned: Bool
    
    func initialize(json: JSON) {
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
        repliesIds = json["replies"].arrayValue.flatMap{
            return $0.int
        }
        isPinned = json["is_pinned"].boolValue
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
        repliesIds = json["replies"].arrayValue.flatMap{
            return $0.int
        }
        isPinned = json["is_pinned"].boolValue    
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
}

struct CommentPostable {
    var parent: Int?
    var target: Int
    var text: String
    
    init(parent: Int? = nil, target: Int, text: String) {
        self.parent = parent
        self.target = target
        self.text = text
    }
    
    var json: [String: AnyObject] {
        var dict : [String: AnyObject] = [
            "target" : target,
            "text" : text
        ]
        if let p = parent {
            dict["parent"] = p
        }
        
        return dict
    }
}