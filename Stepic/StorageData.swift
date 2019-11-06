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
    var dictValue: [String: Any] { get }
}

struct SectionDeadline {
    var section: Int
    var deadlineDate: Date

    init(section: Int, deadlineDate: Date) {
        self.section = section
        self.deadlineDate = deadlineDate
    }

    init?(json: JSON) {
        guard let section = json[JSONKey.section.rawValue].int,
              let deadlineDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.deadline.rawValue]) else {
            return nil
        }

        self.section = section
        self.deadlineDate = deadlineDate
    }

    var dictValue: [String: Any] {
        return [
            JSONKey.section.rawValue: self.section,
            JSONKey.deadline.rawValue: Parser.shared.timedateStringFromDate(date: self.deadlineDate)
        ]
    }

    enum JSONKey: String {
        case section
        case deadline
    }
}

final class DeadlineStorageData: StorageData {
    var courseID: Int
    var deadlines: [SectionDeadline]

    init(courseID: Int, deadlines: [SectionDeadline]) {
        self.courseID = courseID
        self.deadlines = deadlines
    }

    required init(json: JSON) {
        self.courseID = json[JSONKey.course.rawValue].intValue
        self.deadlines = []
        for deadlineJSON in json[JSONKey.deadlines.rawValue].arrayValue {
            if let deadline = SectionDeadline(json: deadlineJSON) {
                self.deadlines += [deadline]
            }
        }
    }

    var dictValue: [String: Any] {
        return [
            JSONKey.course.rawValue: self.courseID,
            JSONKey.deadlines.rawValue: self.deadlines.map { $0.dictValue }
        ]
    }

    enum JSONKey: String {
        case course
        case deadlines
    }
}
