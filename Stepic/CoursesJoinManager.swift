//
//  CoursesJoinManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class CoursesJoinManager: NSObject {
    
    static let sharedManager = CoursesJoinManager()
    fileprivate override init() {}
    
    fileprivate var dCourses = [Course]()
    fileprivate var aCourses = [Course]()
    
    var deletedCourses : [Course] {
        get {
            return dCourses
        }
        
        set(value) {
            var v = value
            removeIntersectedElements(&v, &aCourses)
            dCourses = v
        }
    }
    
    var addedCourses : [Course] {
        get {
            return aCourses
        }
        
        set(value) {
            var v = value
            removeIntersectedElements(&v, &dCourses)
            aCourses = v
        }
    }    
    
    var hasUpdates : Bool {
        return (deletedCourses.count + addedCourses.count) > 0
    }
    
    func clean() {
        deletedCourses = []
        addedCourses = []
    }
}
