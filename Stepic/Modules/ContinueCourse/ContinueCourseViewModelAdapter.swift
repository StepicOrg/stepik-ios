//
//  ContinueCourseViewModelAdapter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension ContinueCourseViewModel {
    init(course: Course) {
        self.title = course.title
        self.coverImageURL = URL(string: course.coverURLString)

        if let progress = course.progress {
            let normalizedPercent = progress.percentPassed / 100.0
            self.progress = (
                description: FormatterHelper.integerPercent(normalizedPercent),
                value: normalizedPercent
            )
        } else {
            self.progress = nil
        }
    }
}
