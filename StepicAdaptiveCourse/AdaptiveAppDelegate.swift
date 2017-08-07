//
//  AppDelegate.swift
//  StepicAdaptiveCourse
//
//  Created by Vladislav Kiryukhin on 23.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Mixpanel
import VK_ios_sdk
import FBSDKCoreKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        AnalyticsHelper.sharedHelper.setupAnalytics()

        if !DefaultsContainer.launch.didLaunch {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.firstOpen, parameters: nil)
            DefaultsContainer.launch.didLaunch = true
        }
        
        LocalNotificationsHelper.registerNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        LocalNotificationsHelper.schedule(notification: .tomorrow)
        LocalNotificationsHelper.schedule(notification: .weekly)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        LocalNotificationsHelper.cancelAllNotifications()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("opened app via url \(url.absoluteString)")
        if VKSdk.processOpen(url, fromApplication: sourceApplication) {
            return true
        }
        if FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        if url.scheme == "vk\(StepicApplicationsInfo.SocialInfo.AppIds.vk)" || url.scheme == "fb\(StepicApplicationsInfo.SocialInfo.AppIds.facebook)" {
            return true
        }
        if let code = Parser.sharedParser.codeFromURL(url) {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: self, userInfo: ["code": code])
        } else {
            print("deep link somehow opened StepicAdaptiveCourse")
        }
        return true
    }

}

