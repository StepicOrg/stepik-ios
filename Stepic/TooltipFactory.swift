//
//  TooltipFactory.swift
//  Stepic
//
//  Created by Ostrenkiy on 19.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TooltipFactory {
    static var sharingCourse: Tooltip {
        return EasyTipTooltip(text: NSLocalizedString("ShareCourseTooltip", comment: ""), shouldDismissAfterTime: true, color: .standard)
    }

    static var lessonDownload: Tooltip {
        return EasyTipTooltip(text: NSLocalizedString("LessonDownloadTooltip", comment: ""), shouldDismissAfterTime: true, color: .standard)
    }

    static var continueLearningWidget: Tooltip {
        return EasyTipTooltip(text: NSLocalizedString("ContinueLearningWidgetTooltip", comment: ""), shouldDismissAfterTime: true, color: .standard)
    }

    static var streaksTooltip: Tooltip {
        return EasyTipTooltip(text: NSLocalizedString("StreaksSwitchTooltip", comment: ""), shouldDismissAfterTime: true, color: .standard)
    }
}
