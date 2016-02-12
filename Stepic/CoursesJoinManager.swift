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
    private override init() {}
    
    var deletedCourses = [Course]()
    var addedCourses = [Course]()
    
    var hasUpdates : Bool {
        return (deletedCourses.count + addedCourses.count) > 0
    }
    
    func clean() {
        deletedCourses = []
        addedCourses = []
    }
}
