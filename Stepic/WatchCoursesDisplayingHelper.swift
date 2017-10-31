//
//  WatchCoursesDisplayingHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 19.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Helper which contains currently displayd courses
 */
class WatchCoursesDisplayingHelper {
    private init() {}

    static func getCurrentlyDisplayingCourses() -> [Course] {
        var enrolledIds = TabsInfo.myCoursesIds

        if CourseSubscriptionManager.sharedManager.hasUpdates {
            print("deleting courses -> \(CourseSubscriptionManager.sharedManager.deletedCourses.count)")
            print("adding courses -> \(CourseSubscriptionManager.sharedManager.addedCourses.count)")

            for id in CourseSubscriptionManager.sharedManager.deletedCourses.map({ $0.id}) {
                if let index = enrolledIds.index(of: id) {
                    enrolledIds.remove(at: index)
                }
            }

            enrolledIds = CourseSubscriptionManager.sharedManager.addedCourses.map({return $0.id}) + enrolledIds
        }

        let courses = try! Course.getCourses(enrolledIds)
        return Sorter.sort(courses, byIds: enrolledIds)
    }
}
