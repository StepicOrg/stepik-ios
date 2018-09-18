//
//  ReportLaunchAnalyticsCommand.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/09/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct ReportLaunchAnalyticsCommand: Command {
    func execute() {
        let launchContainer = LaunchDefaultsContainer()

        if !launchContainer.didLaunch {
            launchContainer.didLaunch = true
            AmplitudeAnalyticsEvents.Launch.firstTime.send()
        }

        AmplitudeAnalyticsEvents.Launch.sessionStart.send()
    }
}
