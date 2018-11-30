//
//  UserNotificationsCenterDelegate.swift
//  Stepic
//
//  Created by Ivan Magda on 16/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UserNotifications

final class UserNotificationsCenterDelegate: NSObject {
    private let splitTestingService: SplitTestingServiceProtocol

    init(
        splitTestingService: SplitTestingServiceProtocol = SplitTestingService(
            analyticsService: AnalyticsUserProperties(),
            storage: UserDefaults.standard
        )
    ) {
        self.splitTestingService = splitTestingService
    }

    func attachNotificationDelegate() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
    }
}

@available(iOS 10.0, *)
extension UserNotificationsCenterDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if AchievementPopupSplitTest.shouldParticipate {
            let popupSplitTest = self.splitTestingService.fetchSplitTest(AchievementPopupSplitTest.self)
            if popupSplitTest.currentGroup.shouldShowAchievementPopup {
                completionHandler([.sound])
            } else {
                completionHandler([.alert, .sound])
            }
        } else {
            completionHandler([.sound])
        }
    }
}
