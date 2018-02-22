//
//  LocalProgressLastViewedUpdater.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class LocalProgressLastViewedUpdater {

    static let shared = LocalProgressLastViewedUpdater()

    func updateView(for step: Step) {
        step.progress?.lastViewed = NSDate().timeIntervalSince1970
        if let unit = step.lesson?.unit {
            updateView(for: unit)
        } else {
            CoreDataHelper.instance.save()
        }
    }

    func updateView(for unit: Unit) {
        unit.progress?.lastViewed = NSDate().timeIntervalSince1970
        if let section = unit.section {
            updateView(for: section)
        } else {
            CoreDataHelper.instance.save()
        }
    }

    func updateView(for section: Section) {
        section.progress?.lastViewed = NSDate().timeIntervalSince1970
        if let course = section.course {
            updateView(for: course)
        } else {
            CoreDataHelper.instance.save()
        }
    }

    func updateView(for course: Course) {
        course.progress?.lastViewed = NSDate().timeIntervalSince1970
        CoreDataHelper.instance.save()
    }

}
