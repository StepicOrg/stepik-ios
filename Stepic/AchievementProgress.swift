//
//  AchievementProgress.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import SwiftyJSON

class AchievementProgress: JSONSerializable {
    var id: Int
    var user: Int
    var achievement: Int
    var score: Int
    var createDate: Date?
    var updateDate: Date?
    var obtainDate: Date?
    var kind: String

    required init(json: JSON) {
        self.id = json["id"].intValue
        self.user = json["user"].intValue
        self.achievement = json["achievement"].intValue
        self.score = json["score"].intValue
        self.kind = json["kind"].stringValue
        self.createDate = Parser.sharedParser.dateFromTimedateJSON(json["create_date"])
        self.updateDate = Parser.sharedParser.dateFromTimedateJSON(json["update_date"])
        self.obtainDate = Parser.sharedParser.dateFromTimedateJSON(json["obtain_date"])
    }

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.user = json["user"].intValue
        self.achievement = json["achievement"].intValue
        self.score = json["score"].intValue
        self.kind = json["kind"].stringValue
        self.createDate = Parser.sharedParser.dateFromTimedateJSON(json["create_date"])
        self.updateDate = Parser.sharedParser.dateFromTimedateJSON(json["update_date"])
        self.obtainDate = Parser.sharedParser.dateFromTimedateJSON(json["obtain_date"])
    }
}
