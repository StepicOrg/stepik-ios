//
//  TooltipFactory.swift
//  Stepic
//
//  Created by Ostrenkiy on 19.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum TooltipFactory {
    static var sharingCourse: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("ShareCourseTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }

    static var lessonDownload: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("LessonDownloadTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }

    static var continueLearningWidget: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("ContinueLearningWidgetTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }

    static var streaksTooltip: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("StreaksSwitchTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }

    static var videoInBackground: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("VideoInBackgroundTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }

    static var codeEditorSettings: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("CodeEditorSettingsTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }

    static var personalDeadlinesButton: Tooltip {
        EasyTipTooltip(
            text: NSLocalizedString("PersonalDeadlinesButtonTooltip", comment: ""),
            shouldDismissAfterTime: true,
            color: .standard
        )
    }
}
