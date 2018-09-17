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
    var id: Int
    var userId: Int
    var courseId: Int
    var isFavorite: Bool
    var lastViewed: Date

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.userId = json["user"].intValue
        self.courseId = json["course"].intValue
        self.isFavorite = json["is_favorite"].boolValue
        self.lastViewed = Parser.sharedParser.dateFromTimedateJSON(json["last_viewed"]) ?? Date()
    }

    required init(json: JSON) {
        self.id = json["id"].intValue
        self.userId = json["user"].intValue
        self.courseId = json["course"].intValue
        self.isFavorite = json["is_favorite"].boolValue
        self.lastViewed = Parser.sharedParser.dateFromTimedateJSON(json["last_viewed"]) ?? Date()
    }
}
