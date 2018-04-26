//
//  CourseViewData.swift
//  Stepic
//
//  Created by Ostrenkiy on 11.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

struct CourseViewData {
    var id: Int
    var title: String
    var isEnrolled: Bool
    var coverURLString: String
    var rating: Float?
    var learners: Int?
    var progress: Float?
    var action: (() -> Void)?
    var secondaryAction: (() -> Void)?
    var isAdaptive: Bool

    init(course: Course, isAdaptive: Bool, action: @escaping () -> Void, secondaryAction: @escaping () -> Void) {
        self.id = course.id
        self.title = course.title
        self.isEnrolled = course.enrolled
        self.coverURLString = course.coverURLString
        self.rating = course.reviewSummary?.average
        self.learners = course.learnersCount
        self.progress = course.enrolled ? course.progress?.percentPassed : nil
        self.action = action
        self.secondaryAction = secondaryAction
        self.isAdaptive = isAdaptive
    }
}
