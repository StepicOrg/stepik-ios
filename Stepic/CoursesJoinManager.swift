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
            dCourses = filterRepetitions(arr: v)
        }
    }
    
    var addedCourses : [Course] {
        get {
            return aCourses
        }
        
        set(value) {
            var v = value
            removeIntersectedElements(&v, &dCourses)
            aCourses = filterRepetitions(arr: v)
        }
    }    
    
    var hasUpdates : Bool {
        return (deletedCourses.count + addedCourses.count) > 0
    }
   
    func filterRepetitions(arr: [Course]) -> [Course] {
        var filtered : [Course] = []
        var distinct : [Course] = []
        
        for c in arr {
            let f = arr.filter({$0.id == c.id}) 
            if f.count != 1 {
                if distinct.index(of: c) == nil {
                    distinct += [c]
                }
            } else {
                filtered += [c]
            }
        }
        return filtered + distinct
    }
    
    func clean() {
        deletedCourses = []
        addedCourses = []
    }
}
