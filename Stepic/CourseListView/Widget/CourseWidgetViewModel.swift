//
//  CourseWidgetViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

struct CourseWidgetProgressViewModel {
    var progress: Float
    var progressLabelText: String
}

struct CourseWidgetViewModel {
    typealias ButtonDescription = (title: String, isCallToAction: Bool)

    var title: String
    var coverImageURL: URL?
    var primaryButtonDescription: ButtonDescription
    var secondaryButtonDescription: ButtonDescription
    var learnersLabelText: String
    var ratingLabelText: String?
    var isAdaptive: Bool
    var progress: CourseWidgetProgressViewModel?
    var courseId: Int
}
