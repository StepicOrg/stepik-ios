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
}

protocol CourseSubscriberProtocol {
    func join(course: Course, source: CourseSubscriptionSource, isWishlisted: Bool?) -> Promise<Course>
    func leave(course: Course, source: CourseSubscriptionSource) -> Promise<Course>
}

extension CourseSubscriberProtocol {
    func join(course: Course, source: CourseSubscriptionSource) -> Promise<Course> {
        self.join(course: course, source: source, isWishlisted: nil)
    }
}

@available(*, deprecated, message: "Legacy code")
final class CourseSubscriber: CourseSubscriberProtocol {
    enum CourseSubscriptionError: Error {
        case error(status: String)
        case badResponseFormat
    }

    private lazy var dataBackUpdateService: DataBackUpdateServiceProtocol = DataBackUpdateService.default

    private let analytics: Analytics

    init(analytics: Analytics = StepikAnalytics.shared) {
        self.analytics = analytics
    }

    func join(course: Course, source: CourseSubscriptionSource, isWishlisted: Bool?) -> Promise<Course> {
        self.performCourseJoinActions(course: course, unsubscribe: false, source: source, isWishlisted: isWishlisted)
    }

    func leave(course: Course, source: CourseSubscriptionSource) -> Promise<Course> {
        self.performCourseJoinActions(course: course, unsubscribe: true, source: source, isWishlisted: nil)
    }

    private func performCourseJoinActions(
        course: Course,
        unsubscribe: Bool,
        source: CourseSubscriptionSource,
        isWishlisted: Bool?
    ) -> Promise<Course> {
        Promise<Course> { seal in
            _ = ApiDataDownloader.enrollments.joinCourse(course, delete: unsubscribe, success: { [weak self] in
                guard let progressId = course.progressId else {
                    seal.reject(CourseSubscriptionError.badResponseFormat)
                    return
                }

                if unsubscribe {
                    self?.analytics.send(.courseUnsubscribed(id: course.id, title: course.title))
                    AnalyticsUserProperties.shared.decrementCoursesCount()
                } else {
                    self?.analytics.send(
                        .courseJoined(source: source, id: course.id, title: course.title, isWishlisted: isWishlisted)
                    )
                    AnalyticsUserProperties.shared.incrementCoursesCount()
                }

                let success: (Course) -> Void = { course in
                    course.enrolled = !unsubscribe
                    CoreDataHelper.shared.save()

                    self?.dataBackUpdateService.triggerEnrollmentUpdate(retrievedCourse: course)

                    seal.fulfill(course)
                }

                ApiDataDownloader.progresses.retrieve(
                    ids: [progressId],
                    existing: course.progress != nil ? [course.progress!] : [],
                    refreshMode: .update,
                    success: { progresses in
                        if !unsubscribe {
                            guard let progress = progresses.first else {
                                seal.reject(CourseSubscriptionError.badResponseFormat)
                                return
                            }
                            course.progress = progress
                        }
                        success(course)
                    },
                    error: { _ in
                        success(course)
                    }
                )
            }, error: { status in
                seal.reject(CourseSubscriptionError.error(status: status))
            })
        }
    }
}
