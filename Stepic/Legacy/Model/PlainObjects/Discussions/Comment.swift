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
    case assistant
    case moderator
}

final class Comment: JSONSerializable {
    var id: Int = -1
    var parentID: IdType?
    var userID: User.IdType = 0
    var userRole: UserRole = .student
    var time = Date()
    var lastTime = Date()
    var text: String = ""
    var replyCount: Int = 0
    var isDeleted: Bool = false
    var targetID: Int = 0
    var repliesIDs: [Int] = []
    var isPinned: Bool = false
    var voteID: String = ""
    var epicCount: Int = 0
    var abuseCount: Int = 0
    var actions: [Action] = []
    var submissionID: Submission.IdType?
    var thread: String = DiscussionThread.ThreadType.default.rawValue

    var userInfo: UserInfo!
    var vote: Vote!
    var submission: Submission?

    var threadType: DiscussionThread.ThreadType? {
        DiscussionThread.ThreadType(rawValue: self.thread)
    }

    var json: JSON {
        var dict: JSON = [
            JSONKey.target.rawValue: self.targetID,
            JSONKey.text.rawValue: self.text,
            JSONKey.thread.rawValue: self.thread
        ]

        if let parentID = self.parentID {
            try? dict.merge(
                with: [
                    JSONKey.parent.rawValue: parentID
                ]
            )
        }

        if let submissionID = self.submissionID {
            try? dict.merge(
                with: [
                    JSONKey.submission.rawValue: submissionID
                ]
            )
        }

        return dict
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    init(
        targetID: Step.IdType,
        text: String,
        parentID: IdType? = nil,
        submissionID: Submission.IdType? = nil,
        threadType: DiscussionThread.ThreadType = .default
    ) {
        self.targetID = targetID
        self.text = text
        self.parentID = parentID
        self.submissionID = submissionID
        self.thread = threadType.rawValue
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
        self.targetID = json[JSONKey.target.rawValue].intValue
        self.repliesIDs = json[JSONKey.replies.rawValue].arrayValue.compactMap { $0.int }
        self.isPinned = json[JSONKey.isPinned.rawValue].boolValue
        self.voteID = json[JSONKey.vote.rawValue].stringValue
        self.epicCount = json[JSONKey.epicCount.rawValue].intValue
        self.abuseCount = json[JSONKey.abuseCount.rawValue].intValue
        self.submissionID = json[JSONKey.submission.rawValue].int
        self.thread = json[JSONKey.thread.rawValue].string ?? DiscussionThread.ThreadType.default.rawValue

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
        case submission
        case submissions
        case attempts
        case thread
    }
}

// MARK: - Comment: CustomDebugStringConvertible -

extension Comment: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        Comment(id: \(id), \
        parentID: \(parentID ??? "nil"), \
        userID: \(userID), \
        userRole: \(userRole), \
        time: \(time), \
        lastTime: \(lastTime), \
        text: \(text), \
        replyCount: \(replyCount), \
        isDeleted: \(isDeleted), \
        targetID: \(targetID), \
        repliesIDs: \(repliesIDs), \
        isPinned: \(isPinned), \
        voteID: \(voteID), \
        epicCount: \(epicCount), \
        abuseCount: \(abuseCount), \
        actions: \(actions), \
        submissionID: \(submissionID ??? "nil"), \
        userInfo: \(userInfo ??? "nil"), \
        vote: \(vote ??? "nil"), \
        submission: \(submission ??? "nil")) \
        thread: \(thread))
        """
    }
}
