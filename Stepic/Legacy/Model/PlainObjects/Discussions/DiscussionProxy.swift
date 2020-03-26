//
//  DiscussionProxy.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

final class DiscussionProxy: JSONSerializable {
    var id: String = ""
    var discussionsIDs: [Comment.IdType] = []
    var discussionsIDsMostLiked: [Comment.IdType] = []
    var discussionsIDsMostActive: [Comment.IdType] = []
    var discussionsIDsRecentActivity: [Comment.IdType] = []

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].stringValue
        self.discussionsIDs = json[JSONKey.discussions.rawValue].arrayValue.compactMap { $0.int }
        self.discussionsIDsMostLiked = json[JSONKey.discussionsMostLiked.rawValue].arrayValue.compactMap { $0.int }
        self.discussionsIDsMostActive = json[JSONKey.discussionsMostActive.rawValue].arrayValue.compactMap { $0.int }
        self.discussionsIDsRecentActivity = json[JSONKey.discussionsRecentActivity.rawValue].arrayValue.compactMap { $0.int }
    }

    enum JSONKey: String {
        case id
        case discussions
        case discussionsMostLiked = "discussions_most_liked"
        case discussionsMostActive = "discussions_most_active"
        case discussionsRecentActivity = "discussions_recent_activity"
    }
}
