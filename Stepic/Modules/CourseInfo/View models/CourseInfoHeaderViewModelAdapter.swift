//
//  CourseInfoHeaderViewModelAdapter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.12.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension CourseInfoHeaderViewModel {
    init(course: Course) {
        self.title = course.title
        self.coverImageURL = URL(string: course.coverURLString)

        self.rating = {
            if let reviewsCount = course.reviewSummary?.count,
               let averageRating = course.reviewSummary?.average,
               reviewsCount > 0 {
                return Int(round(averageRating))
            }
            return 0
        }()

        self.progress = {
            if let progress = course.progress {
                return CourseInfoProgressViewModel(progress: progress)
            }
            return nil
        }()

        self.learnersLabelText = FormatterHelper.longNumber(course.learnersCount ?? 0)
        self.isVerified = (course.readiness ?? 0) > 0.9
        self.isEnrolled = course.enrolled
    }
}

extension CourseInfoProgressViewModel {
    init(progress: Progress) {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)
        self.progress = normalizedPercent / 100.0
        self.progressLabelText = FormatterHelper.integerPercent(Int(normalizedPercent))
    }
}
