//
//  CourseSubscriber.swift
//  Stepic
//
//  Created by Ostrenkiy on 07.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class CourseSubscriber {

    enum CourseSubscriptionError: Error {
        case error(status: String)
        case badResponseFormat
    }

    func join(course: Course) -> Promise<Course> {
        return Promise<Course> {
            fulfill, reject in
            _ = ApiDataDownloader.enrollments.joinCourse(course, success: {
                guard let progressId = course.progressId else {
                    reject(CourseSubscriptionError.badResponseFormat)
                    return
                }
                let success: (Course) -> Void = {
                    course in
                    CoreDataHelper.instance.save()
                    CourseSubscriptionManager.sharedManager.subscribedTo(course: course)
                    WatchDataHelper.parseAndAddPlainCourses(WatchCoursesDisplayingHelper.getCurrentlyDisplayingCourses())
                    fulfill(course)
                }
                ApiDataDownloader.progresses.retrieve(ids: [progressId], existing: course.progress != nil ? [course.progress!] : [], refreshMode: .update, success: {
                    progresses in
                    guard let progress = progresses.first else {
                        reject(CourseSubscriptionError.badResponseFormat)
                        return
                    }
                    course.progress = progress
                    success(course)
                }, error: {
                    _ in
                    success(course)
                })
            }, error: {
                status in
                reject(CourseSubscriptionError.error(status: status))
            })
        }
    }
}
