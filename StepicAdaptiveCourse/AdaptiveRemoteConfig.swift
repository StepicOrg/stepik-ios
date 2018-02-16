//
//  AdaptiveRemoteConfig.swift
//  Adaptive 1838
//
//  Created by Vladislav Kiryukhin on 15.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

enum AdaptiveRemoteConfigKeys: String {
    case coursesInfoUrl = "adaptive_courses_info_url"
}

extension RemoteConfig {
    var adaptiveCoursesInfoUrl: String {
        // Dirty way to extend base class: re-import defaults
        var defaults = appDefaults
        defaults[AdaptiveRemoteConfigKeys.coursesInfoUrl.rawValue] = StepicApplicationsInfo.adaptiveCoursesInfoURL as NSObject
        FIRRemoteConfig.remoteConfig().setDefaults(defaults)

        guard let configValue = FIRRemoteConfig.remoteConfig().configValue(forKey: AdaptiveRemoteConfigKeys.coursesInfoUrl.rawValue).stringValue else {
            return StepicApplicationsInfo.adaptiveCoursesInfoURL
        }

        return configValue
    }
}
