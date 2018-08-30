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
        self.init(
            title: course.title,
            coverImage: UIImage(),
            primaryButtonDescription: ButtonDescription(title: "1", isCallToAction: false),
            secondaryButtonDescription: ButtonDescription(title: "1", isCallToAction: false),
            learnersLabelText: "10k",
            ratingLabelText: "4.2",
            isAdaptive: true,
            progress: nil
        )
    }
}
