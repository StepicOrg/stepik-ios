//
//  CoursesJoinManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

extension Foundation.Notification.Name {
    static let courseSubscribedNotification = Foundation.Notification.Name("CourseSubscribedNotification")
    static let courseUnsubscribedNotification = Foundation.Notification.Name("CourseUnsubscribedNotification")
}

@available(*, deprecated, message: "Legacy class; watchOS code depends on it")
class CourseSubscriptionManager: NSObject {

    static let sharedManager = CourseSubscriptionManager()

    private lazy var dataBackUpdateService: DataBackUpdateServiceProtocol = {
        let service = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
        return service
    }()

    var handleUpdatesBlock: (() -> Void)?
    override init() {}

    func startObservingOtherSubscriptionManagers() {
        NotificationCenter.default.addObserver(self, selector: #selector(CourseSubscriptionManager.courseSubscribed(_:)), name: .courseSubscribedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CourseSubscriptionManager.courseUnsubscribed(_:)), name: .courseUnsubscribedNotification, object: nil)
    }

    fileprivate var dCourses = [Course]()
    fileprivate var aCourses = [Course]()

    @objc func courseSubscribed(_ notification: Foundation.Notification) {
        if let course = (notification as NSNotification).userInfo?["course"] as? Course {
            subscribedTo(course: course, notifyOthers: false)
        }
    }

    @objc func courseUnsubscribed(_ notification: Foundation.Notification) {
        if let course = (notification as NSNotification).userInfo?["course"] as? Course {
            unsubscribedFrom(course: course, notifyOthers: false)
        }
    }

    var deletedCourses: [Course] {
        get {
            return dCourses
        }

        set(value) {
            var v = value
            removeIntersectedElements(&v, &aCourses)
            dCourses = filterRepetitions(arr: v)
        }
    }

    var addedCourses: [Course] {
        get {
            return aCourses
        }

        set(value) {
            var v = value
            removeIntersectedElements(&v, &dCourses)
            aCourses = filterRepetitions(arr: v)
        }
    }

    func unsubscribedFrom(course: Course, notifyOthers: Bool = true) {
        // New service call
        self.dataBackUpdateService.triggerEnrollmentUpdate(retrievedCourse: course)

        deletedCourses += [course]
        handleUpdatesBlock?()
        if notifyOthers {
            // FIXME: Replace two different notifications with one from NSNotification.Name extension
            NotificationCenter.default.post(name: .courseUnsubscribedNotification, object: nil, userInfo: ["course": course])
            #if os(tvOS)
            NotificationCenter.default.post(name: .courseUnsubscribed, object: nil, userInfo: ["id": course.id])
            #endif
        }
    }

    func subscribedTo(course: Course, notifyOthers: Bool = true) {
        // New service call
        self.dataBackUpdateService.triggerEnrollmentUpdate(retrievedCourse: course)

        addedCourses += [course]
        handleUpdatesBlock?()
        if notifyOthers {
            // FIXME: Replace two different notifications with one from NSNotification.Name extension
            NotificationCenter.default.post(name: .courseSubscribedNotification, object: nil, userInfo: ["course": course])
            #if os(tvOS)
                NotificationCenter.default.post(name: .courseSubscribed, object: nil, userInfo: ["course": course])
            #endif
        }
    }

    var hasUpdates: Bool {
        return (deletedCourses.count + addedCourses.count) > 0
    }

    func filterRepetitions(arr: [Course]) -> [Course] {
        var filtered: [Course] = []
        var distinct: [Course] = []

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
