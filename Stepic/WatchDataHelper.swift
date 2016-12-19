//
//  WatchDataHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class WatchDataHelper {
    
    private init(){}
    
    @available(iOS 9.0, *)
    static func parseAndAddPlainCourses(_ courses: [Course]) {
        var plainCourses: [CoursePlainEntity] = []
        var limit = 5
        for course in courses {
            if limit == 0 {
                break
            }
            
            let plainCourse = CoursePlainEntity(name: course.title, metainfo: course.metaInfo, imageURL: course.coverURLString)
            plainCourses.append(plainCourse)
            
            limit -= 1
        }
        
        let data = [WatchSessionSender.Name.Courses: plainCourses.toData()]
        let success = WatchSessionManager.sharedManager.sendMessage(message: data)
        
        if !success {
            do {
                try WatchSessionManager.sharedManager.updateApplicationContext(applicationContext: data)
            }
            catch { }
        }
    }
}
