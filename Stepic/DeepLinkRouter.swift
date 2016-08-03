//
//  DeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class DeepLinkRouter {
    
    static func routeFromDeepLink(link: NSURL) {
        func getCourseID(string: String) -> Int? {
            var courseString = ""
            for character in string.characters.reverse() {
                if let num = Int("\(character)") {
                    courseString = "\(character)" + courseString
                } else {
                    break
                }
            }
            let courseId = Int(courseString)
            
            return courseId
        }
        
        if let components = link.pathComponents {
            //just a check if everything is OK with the link length
            if components.count < 2 {
                return 
            }
            
            if components[1].lowercaseString == "course" {
                if let courseId = getCourseID(components[2]) {
                    if components.count == 3 {
                        routeToCourseWithId(courseId)
                    }
                    if components.count == 4 && components[3].lowercaseString.containsString("syllabus") {
                        routeToSyllabusWithId(courseId)
                    }
                } 
            }
        }
    }
    
    private static func routeToCourseWithId(courseId: Int) {
        
    }
    
    private static func routeToSyllabusWithId(courseId: Int) {
        
    }
}