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
    let isAuthorized: Bool

    private let splitTestingService = SplitTestingService(analyticsService: AnalyticsUserProperties(), storage: UserDefaults.standard)

    func makePrimary() -> CourseWidgetViewModel.ButtonDescription {
        let joinTitle = NSLocalizedString("WidgetButtonJoin", comment: "")

        let title = self.course.enrolled && isAuthorized
            ? NSLocalizedString("WidgetButtonLearn", comment: "")
            : joinTitle
        return CourseWidgetViewModel.ButtonDescription(
            title: title,
            isCallToAction: !self.course.enrolled || !isAuthorized
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
