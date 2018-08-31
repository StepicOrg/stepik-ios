//
//  CourseWidgetViewModelAdapter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension CourseWidgetViewModel {
    init(course: Course) {
        var progressViewModel: CourseWidgetProgressViewModel?
        if let progress = course.progress {
            progressViewModel = CourseWidgetProgressViewModel(progress: progress)
        }

        var ratingLabelText: String?
        if let reviewsCount = course.reviewSummary?.count,
           let averageRating = course.reviewSummary?.average,
           reviewsCount > 0 {
            ratingLabelText = FormatterHelper.averageRating(averageRating)
        }

        self.init(
            title: course.title,
            coverImageURL: URL(string: course.coverURLString),
            primaryButtonDescription: ButtonDescription(title: "Join", isCallToAction: true),
            secondaryButtonDescription: ButtonDescription(title: "Info", isCallToAction: false),
            learnersLabelText: FormatterHelper.longNumber(course.learnersCount ?? 0),
            ratingLabelText: ratingLabelText,
            isAdaptive: true,
            progress: progressViewModel
        )
    }
}

extension CourseWidgetProgressViewModel {
    init(progress: Progress) {
        var normalizedPercent = progress.percentPassed
        normalizedPercent.round(.up)
        self.progress = normalizedPercent / 100.0
        self.progressLabelText = FormatterHelper.integerPercent(Int(normalizedPercent))
    }
}
