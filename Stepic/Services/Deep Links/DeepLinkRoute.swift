//
//  DeepLinkRoute.swift
//  Stepic
//
//  Created by Ostrenkiy on 12/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Regex

enum DeepLinkRoute {
    case lesson(lessonID: Int, stepID: Int, unitID: Int?)
    case notifications(section: NotificationsSection)
    case discussions(lessonID: Int, stepID: Int, discussionID: Int, unitID: Int?)
    case profile(userID: Int)
    case syllabus(courseID: Int)
    case catalog
    case home
    case course(courseID: Int)

    init?(path: String) {
        if let match = Pattern.catalog.regex.firstMatch(in: path),
            match.matchedString == path {
            self = .catalog
            return
        }

        if let match = Pattern.course.regex.firstMatch(in: path),
            let courseIDString = match.captures[0],
            let courseID = Int(courseIDString),
            match.matchedString == path {
            self = .course(courseID: courseID)
            return
        }

        if let match = Pattern.profile.regex.firstMatch(in: path),
            let userIDString = match.captures[0], let userID = Int(userIDString),
            match.matchedString == path {
            self = .profile(userID: userID)
            return
        }

        if let match = Pattern.notifications.regex.firstMatch(in: path),
            match.matchedString == path {
            self = .notifications(section: .all)
            return
        }

        if let match = Pattern.syllabus.regex.firstMatch(in: path),
            let courseIDString = match.captures[0],
            let courseID = Int(courseIDString),
            match.matchedString == path {
            self = .syllabus(courseID: courseID)
            return
        }

        if let match = Pattern.lesson.regex.firstMatch(in: path),
            let lessonIDString = match.captures[0], let lessonID = Int(lessonIDString),
            let stepIDString = match.captures[1], let stepID = Int(stepIDString),
            match.matchedString == path {
            let unitID = match.captures[2].flatMap { Int($0) }
            self = .lesson(lessonID: lessonID, stepID: stepID, unitID: unitID)
            return
        }

        if let match = Pattern.discussions.regex.firstMatch(in: path),
            let lessonIDString = match.captures[0], let lessonID = Int(lessonIDString),
            let stepIDString = match.captures[1], let stepID = Int(stepIDString),
            let discussionIDString = match.captures[2], let discussionID = Int(discussionIDString),
            match.matchedString == path {
            let unitID = match.captures[3].flatMap { Int($0) }
            self = .discussions(lessonID: lessonID, stepID: stepID, discussionID: discussionID, unitID: unitID)
            return
        }
        return nil
    }

    enum Pattern: String {
        case catalog = "https:\\/\\/stepik.org\\/catalog\\/?"
        case course = "https:\\/\\/stepik.org\\/(?:course\\/|course\\/[a-zа-я-]+|)(\\d+)\\/?(?:((?=[?])[a-zа-я0-9=?&_-]*)|)"
        case profile = "https:\\/\\/stepik.org\\/users\\/(\\d+)\\/?"
        case notifications = "https:\\/\\/stepik.org\\/notifications\\/?"
        case syllabus = "https:\\/\\/stepik.org\\/(?:course\\/|course\\/[a-zа-я-]+)(\\d+)\\/syllabus\\/?[a-zа-я0-9=?&_-]*"
        case lesson = "https:\\/\\/stepik.org\\/(?:lesson\\/|lesson\\/[a-zа-я-]+)(\\d+)\\/step\\/(\\d+)(?:\\?unit=(\\d+))?\\/?"
        case discussions = "https:\\/\\/stepik.org\\/(?:lesson\\/|lesson\\/[a-zа-я-]+)(\\d+)\\/step\\/(\\d+)(?:\\?discussion=(\\d+))(?:\\&unit=(\\d+))?\\/?"

        var regex: Regex {
            return try! Regex(string: self.rawValue, options: [.ignoreCase])
        }
    }
}
