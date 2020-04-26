//
//  UserCourse.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UserCourse: JSONSerializable {
    var id: Int = 0
    var userID: Int = 0
    var courseID: Int = 0
    var isFavorite: Bool = false
    var isArchived: Bool = false
    var lastViewed: Date = Date()

    var json: JSON {
        [
            JSONKey.isFavorite.rawValue: self.isFavorite,
            JSONKey.isArchived.rawValue: self.isArchived,
            JSONKey.course.rawValue: self.courseID
        ]
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.userID = json[JSONKey.user.rawValue].intValue
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.isFavorite = json[JSONKey.isFavorite.rawValue].boolValue
        self.isArchived = json[JSONKey.isArchived.rawValue].boolValue
        self.lastViewed = Parser.shared.dateFromTimedateJSON(json[JSONKey.lastViewed.rawValue]) ?? Date()
    }

    enum JSONKey: String {
        case id
        case user
        case course
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case lastViewed = "last_viewed"
    }
}
