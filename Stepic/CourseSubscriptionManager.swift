//
//  CoursesJoinManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class CourseSubscriptionManager: NSObject {

    static let sharedManager = CourseSubscriptionManager()

    let courseSubscribedNotificationName = NSNotification.Name(rawValue: "CourseSubscribedNotification")
    let courseUnsubscribedNotificationName = NSNotification.Name(rawValue: "CourseUnsubscribedNotification")

    var handleUpdatesBlock: (() -> Void)?
    override init() {}

    func startObservingOtherSubscriptionManagers() {
        NotificationCenter.default.addObserver(self, selector: #selector(CourseSubscriptionManager.courseSubscribed(_:)), name: courseSubscribedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CourseSubscriptionManager.courseUnsubscribed(_:)), name: courseUnsubscribedNotificationName, object: nil)
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
        deletedCourses += [course]
        handleUpdatesBlock?()
        if notifyOthers {
            NotificationCenter.default.post(name: courseUnsubscribedNotificationName, object: nil, userInfo: ["course": course])
        }
    }

    func subscribedTo(course: Course, notifyOthers: Bool = true) {
        addedCourses += [course]
        handleUpdatesBlock?()
        if notifyOthers {
            NotificationCenter.default.post(name: courseSubscribedNotificationName, object: nil, userInfo: ["course": course])
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
