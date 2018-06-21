//
//  AnalyticsUserProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Amplitude_iOS

class AnalyticsUserProperties {
    
    private func setAmplitudeProperty(key: String, value: Any) {
        Amplitude.instance().setUserProperties([key: value])
    }
    
    func setUserID(to id: Int) {
        setAmplitudeProperty(key: "user_id", value: id)
    }
    
    func setSubmissionsMade(count: Int) {
        setAmplitudeProperty(key: "submissions_made", value: count)
    }
    
    func setCoursesCount(count: Int) {
        setAmplitudeProperty(key: "courses_count", value: count)
    }
    
    func setPushPermission(isGranted: Bool) {
        setAmplitudeProperty(key: "push_permission", value: isGranted ? "granted" : "not_granted")
    }
    
    func setStreaksNotificationsEnabled(isEnabled: Bool) {
        setAmplitudeProperty(key: "streaks_notifications_enabled", value: isEnabled ? "enabled" : "disabled")
    }
    
    func setScreenOrientation(isPortrait: Bool) {
        setAmplitudeProperty(key: "screen_orientation", value: isPortrait ? "portrait" : "landscape")
    }
    
    func setApplicationID(id: String) {
        setAmplitudeProperty(key: "application_id", value: id)
    }
}
