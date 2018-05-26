//
//  StorageData.swift
//  Stepic
//
//  Created by Ostrenkiy on 23.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol StorageData {
    init(json: JSON)
    var dictValue: [String : Any] {
        get
    }
}

struct SectionDeadline {
    var section: Int
    var deadlineDate: Date
    init(section: Int, deadlineDate: Date) {
        self.section = section
        self.deadlineDate = deadlineDate
    }

    init?(json: JSON) {
        guard let section = json["section"].int, let deadlineDate = Parser.sharedParser.dateFromTimedateJSON(json["deadline"]) else {
            return nil
        }
        self.section = section
        self.deadlineDate = deadlineDate
    }

    var dictValue: [String : Any] {
        return [
            "section": section,
            "deadline": Parser.sharedParser.timedateStringFromDate(date: deadlineDate)
        ]
    }
}

class DeadlineStorageData: StorageData {
    var courseID: Int
    var deadlines: [SectionDeadline]

    required init(json: JSON) {
        courseID = json["course"].intValue
        deadlines = []
        for deadlineJSON in json["deadlines"].arrayValue {
            if let deadline = SectionDeadline(json: deadlineJSON) {
                deadlines += [deadline]
            }
        }
    }

    var dictValue: [String : Any] {
        return [:]
    }
}
