//
//  DeepLinkRoutingService.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Regex

class DeepLinkRoutingService {
    enum Route {
        case lesson(lessonID: Int, stepID: Int, unitID: Int?)
        case notifications
        case discussions(lessonID: Int, stepID: Int, discussionID: Int, unitID: Int?)
        case profile(userID: Int)
        case syllabus(courseID: Int)
        case catalog
        case course(courseID: Int)
        
        var regexString: String {
            switch self {
            case .catalog:
                return "https:\\/\\/stepik.org\\/catalog\\/?"
            case .course:
                return "https:\\/\\/stepik.org\\/(?:course\\/|course\\/[a-zа-я-]+|)(\\d+)\\/?"
            case .profile:
                return "https:\\/\\/stepik.org\\/users\\/(\\d+)\\/?"
            case .notifications:
                return "https:\\/\\/stepik.org\\/notifications\\/?"
            case .syllabus:
                return "https:\\/\\/stepik.org\\/(?:course\\/|course\\/[a-zа-я-]+)(\\d+)\\/syllabus\\/?"
            case .lesson:
                return "https:\\/\\/stepik.org\\/(?:lesson\\/|lesson\\/[a-zа-я-]+)(\\d+)\\/step\\/(\\d+)(?:\\?unit=(\\d+))?\\/?"
            case .discussions:
                return "https:\\/\\/stepik.org\\/(?:lesson\\/|lesson\\/[a-zа-я-]+)(\\d+)\\/step\\/(\\d+)(?:\\?discussion=(\\d+))(?:\\&unit=(\\d+))?\\/?"
            }
        }
        
        var regex: Regex {
            return try! Regex(string: self.regexString, options: [.ignoreCase])
        }
        
        init?(path: String) {
            if let match = Route.catalog.regex.firstMatch(in: path), match.matchedString == path {
                self = .catalog
                return
            }
            
            if let match = Route.course(courseID: 0).regex.firstMatch(in: path),
               let courseIDString = match.captures[0], let courseID = Int(courseIDString),
               match.matchedString == path {
                self = .course(courseID: courseID)
                return
            }
            
            if let match = Route.profile(userID: 0).regex.firstMatch(in: path),
               let userIDString = match.captures[0], let userID = Int(userIDString),
               match.matchedString == path {
                self = .profile(userID: userID)
                return
            }
            
            if let match = Route.notifications.regex.firstMatch(in: path), match.matchedString == path {
               self = .notifications
                return
            }
            
            if let match = Route.syllabus(courseID: 0).regex.firstMatch(in: path),
               let courseIDString = match.captures[0], let courseID = Int(courseIDString),
               match.matchedString == path {
                self = .syllabus(courseID: courseID)
                return
            }
            
            if let match = Route.lesson(lessonID: 0, stepID: 0, unitID: nil).regex.firstMatch(in: path),
               let lessonIDString = match.captures[0], let lessonID = Int(lessonIDString),
               let stepIDString = match.captures[1], let stepID = Int(stepIDString),
               match.matchedString == path {
                let unitID = match.captures[2].flatMap { Int($0) }
                self = .lesson(lessonID: lessonID, stepID: stepID, unitID: unitID)
                return
            }
            
            if let match = Route.discussions(lessonID: 0, stepID: 0, discussionID: 0, unitID: nil).regex.firstMatch(in: path),
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
    }
    
    func route(path: String) {
        guard let route = Route(path: path) else {
            //TODO: add fail here
            return
        }
        
        
    }
}
