//
//  ButtonDescriptionFactory.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct ButtonDescriptionFactory {
    let course: Course

    func makePrimary() -> CourseWidgetViewModel.ButtonDescription {
        let title = self.course.enrolled
            ? NSLocalizedString("WidgetButtonLearn", comment: "")
            : NSLocalizedString("WidgetButtonJoin", comment: "")
        return CourseWidgetViewModel.ButtonDescription(
            title: title,
            isCallToAction: !self.course.enrolled
        )
    }

    func makeSecondary(isAdaptive: Bool) -> CourseWidgetViewModel.ButtonDescription {
        var title: String
        if isAdaptive {
            title = NSLocalizedString("WidgetButtonInfo", comment: "")
        } else {
            title = self.course.enrolled
                ? NSLocalizedString("WidgetButtonSyllabus", comment: "")
                : NSLocalizedString("WidgetButtonInfo", comment: "")
        }
        return CourseWidgetViewModel.ButtonDescription(
            title: title,
            isCallToAction: false
        )
    }
}
