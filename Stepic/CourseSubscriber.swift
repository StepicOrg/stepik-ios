//
//  CourseSubscriber.swift
//  Stepic
//
//  Created by Ostrenkiy on 07.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

enum CourseSubscriptionSource: String {
    case widget
    case preview
    case courseInfoTab
}

protocol CourseSubscriberProtocol {
    func join(course: Course, source: CourseSubscriptionSource) -> Promise<Course>
    func leave(course: Course, source: CourseSubscriptionSource) -> Promise<Course>
}

@available(*, deprecated, message: "Legacy code")
class CourseSubscriber: CourseSubscriberProtocol {

    enum CourseSubscriptionError: Error {
        case error(status: String)
        case badResponseFormat
    }

    func join(course: Course, source: CourseSubscriptionSource) -> Promise<Course> {
        return performCourseJoinActions(course: course, unsubscribe: false, source: source)
    }

    func leave(course: Course, source: CourseSubscriptionSource) -> Promise<Course> {
        return performCourseJoinActions(course: course, unsubscribe: true, source: source)
    }

    private func performCourseJoinActions(course: Course, unsubscribe: Bool, source: CourseSubscriptionSource) -> Promise<Course> {
        return Promise<Course> { seal in

            _ = ApiDataDownloader.enrollments.joinCourse(course, delete: unsubscribe, success: {
                guard let progressId = course.progressId else {
                    seal.reject(CourseSubscriptionError.badResponseFormat)
                    return
                }

                if unsubscribe {
                    AmplitudeAnalyticsEvents.Course.unsubscribed(courseID: course.id, courseTitle: course.title).send()
                    AnalyticsUserProperties.shared.decrementCoursesCount()
                } else {
                    AmplitudeAnalyticsEvents.Course.joined(source: source.rawValue, courseID: course.id, courseTitle: course.title).send()
                    AnalyticsUserProperties.shared.incrementCoursesCount()
                }

                let success: (Course) -> Void = {
                    course in
                    course.enrolled = !unsubscribe
                    CoreDataHelper.instance.save()

                    if unsubscribe {
                        CourseSubscriptionManager.sharedManager.unsubscribedFrom(course: course)
                    } else {
                        CourseSubscriptionManager.sharedManager.subscribedTo(course: course)
                    }

                    #if !os(tvOS)
                        WatchDataHelper.parseAndAddPlainCourses(WatchCoursesDisplayingHelper.getCurrentlyDisplayingCourses())
                    #endif

                    seal.fulfill(course)
                }

                ApiDataDownloader.progresses.retrieve(ids: [progressId], existing: course.progress != nil ? [course.progress!] : [], refreshMode: .update, success: {
                    progresses in

                    if (!unsubscribe) {
                        guard let progress = progresses.first else {
                            seal.reject(CourseSubscriptionError.badResponseFormat)
                            return
                        }
                        course.progress = progress
                    }
                    success(course)
                }, error: {
                    _ in
                    success(course)
                })
            }, error: { status in
                seal.reject(CourseSubscriptionError.error(status: status))
            })
        }
    }
}
