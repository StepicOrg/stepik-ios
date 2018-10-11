//
//  NotificationService.swift
//  Stepic
//
//  Created by Ivan Magda on 11/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class NotificationService: NSObject {
    
    static let shared = NotificationService()
    
    private override init() {
        super.init()
    }
    
    // MARK: Public API
    
    func handleApplicationLaunchOptions(_ launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard let launchOptions = launchOptions else {
            return
        }
        
        if let localNotification = launchOptions[.localNotification] as? [String: Any] {
            handleLocalNotification(localNotification)
        } else if let remoteNotification = launchOptions[.remoteNotification] as? [String: Any] {
            handleRemoteNotification(remoteNotification)
        }
    }
    
    // MARK: Private API
    
    private func handleLocalNotification(_ notification: [String: Any]) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened)
    }
    
    private func handleRemoteNotification(_ notification: [String: Any]) {
//        guard let reaction = NotificationReactionHandler.handle(with: notification),
//              let topController = self.currentNavigationController?.topViewController else {
//            return
//        }
//        reaction(topController)
        print(notification)
    }
}
