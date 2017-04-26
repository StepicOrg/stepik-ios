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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Mixpanel.initialize(token: "cc80751831012d6a0de6bba73ec2f556")
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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

