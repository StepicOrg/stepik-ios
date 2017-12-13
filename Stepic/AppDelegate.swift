//
//  AppDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import MediaPlayer
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift
import SVProgressHUD
import VK_ios_sdk
import FBSDKCoreKit
import Mixpanel
import YandexMobileMetrica
import Presentr
import SwiftyJSON
import PromiseKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AnalyticsHelper.sharedHelper.setupAnalytics()

        WatchSessionManager.sharedManager.startSession()

        NotificationsBadgesManager.shared.setup()

        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        ConnectionHelper.shared.instantiate()
        if !AudioManager.sharedManager.initAudioSession() {
            print("Could not initialize audio session")
        }

        FIRAppIndexing.sharedInstance().registerApp(Tokens.shared.firebaseId)

        AnalyticsReporter.reportMixpanelEvent(AnalyticsEvents.App.opened, parameters: nil)

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didReceiveRegistrationToken(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBadgeUpdate(systemNotification:)), name: .badgeUpdated, object: nil)

        ExecutionQueues.sharedQueues.setUpQueueObservers()
        ExecutionQueues.sharedQueues.recoverQueuesFromPersistentStore()
        ExecutionQueues.sharedQueues.executeConnectionAvailableQueue()

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        if StepicApplicationsInfo.inAppUpdatesAvailable {
            checkForUpdates()
        }

        if AuthInfo.shared.isAuthorized {
            NotificationRegistrator.sharedInstance.registerForRemoteNotifications(application)
        }

        if (launchOptions?[UIApplicationLaunchOptionsKey.localNotification]) != nil {
            handleLocalNotification()
        }

        if let notificationDict = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: Any] {
            handleNotification(notificationDict: notificationDict)
        }

        checkNotificationsCount()

        return true
    }

    @objc func didBadgeUpdate(systemNotification: Foundation.Notification) {
        guard let userInfo = systemNotification.userInfo,
            let value = userInfo["value"] as? Int else {
                return
        }

        UIApplication.shared.applicationIconBadgeNumber = value
    }

    //Notification handling
    func checkNotificationsCount() {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        ApiDataDownloader.notificationsStatusAPI.retrieve().then { result -> Void in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { _ in
            print("notifications: unable to fetch badges count on launch")
            NotificationsBadgesManager.shared.set(number: 0)
        }
    }

    func handleLocalNotification() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened, parameters: nil)
    }

    func handleNotification(notificationDict: [String: Any]) {
        if let reaction = NotificationReactionHandler.handle(with: notificationDict),
            let topController = self.currentNavigation?.topViewController {
            reaction(topController)
        }
    }

    var currentNavigation: UINavigationController? {
        if let tabController = window?.rootViewController as? UITabBarController {
            let cnt = tabController.viewControllers?.count ?? 0
            let index = tabController.selectedIndex
            if index < cnt {
                return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
            } else {
                return tabController.viewControllers?[0] as? UINavigationController
            }
        }
        return nil
    }

    fileprivate func handleOpenedFromDeepLink(_ url: URL) {
        DeepLinkRouter.routeFromDeepLink(url, completion: {
            [weak self]
            controllers in
            if controllers.count > 0 {
                if let s = self {
                    if let topController = s.currentNavigation?.topViewController {
                        delay(0.5, closure: {
                            for (index, vc) in controllers.enumerated() {
                                if index == controllers.count - 1 {
                                    topController.navigationController?.pushViewController(vc, animated: true)
                                } else {
                                    topController.navigationController?.pushViewController(vc, animated: false)
                                }
                            }
                        })
                    }
                }
            } else {
                let alert = UIAlertController(title: NSLocalizedString("CouldNotOpenLink", comment: ""), message: NSLocalizedString("OpenInBrowserQuestion", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
                    _ in
                    UIApplication.shared.openURL(url)
                }))

                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))

                UIThread.performUI {
                    self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        })
    }

    func updateNotificationRegistrationStatus(_ notification: Foundation.Notification) {
        if let info = (notification as NSNotification).userInfo as? [String:String] {
            if let error = info["error"] {
                print("Error registering with GCM: \(error)")
            } else if let _ = info["registrationToken"] {
                print("Token registration successful!")
            }
        }
    }

    func checkForUpdates() {
        UpdateChecker.sharedChecker.checkForUpdatesIfNeeded({
                newVersion in
                if let version = newVersion {
                    let alert = VersionUpdateAlertConstructor.sharedConstructor.getUpdateAlertController(updateUrl: version.url, addNeverAskAction: true)
                    UIThread.performUI {
                        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }, error: {
                error in
                print("error while checking for updates: \(error.code) \(error.localizedDescription)")
        })
    }

    func didReceiveRegistrationToken(_ notification: Foundation.Notification) {
        if let token = FIRInstanceID.instanceID().token() {
            if AuthInfo.shared.isAuthorized {
                NotificationRegistrator.sharedInstance.registerDevice(token)
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationRegistrator.sharedInstance.getGCMRegistrationToken(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("error while registering to remote notifications")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("remote notification received: DEBUG = \(userInfo)")

        guard let notificationDict = userInfo as? [String: Any] else {
            print("remote notification received: unable to parse userInfo")
            return
        }

        guard let type = notificationDict["type"] as? String else {
            print("remote notification received: unable to parse notification type")
            return
        }

        switch type {
        case "notifications":
            if let text = ((notificationDict["aps"] as? [String: Any])?["alert"] as? [String: Any])?["body"] as? String {
                // FIXME: incapsulate this logic
                var notification: Notification?
                guard let object = notificationDict["object"] as? String else {
                    return
                }
                let json = JSON(parseJSON: object)
                if let notificationId = json["id"].int,
                   let notification = Notification.fetch(id: notificationId) {
                    notification.update(json: json)
                    NotificationCenter.default.post(name: .notificationAdded, object: nil, userInfo: ["id": notification.id, "new": false])
                } else {
                    notification = Notification(json: json)
                    NotificationCenter.default.post(name: .notificationAdded, object: nil, userInfo: ["id": notification!.id, "new": true])
                }
                CoreDataHelper.instance.save()

                NotificationAlertConstructor.sharedConstructor.presentNotificationFake(text, success: {
                    self.handleNotification(notificationDict: notificationDict)
                })
            }
        case "notification-statuses":
            if let badgeCount = (notificationDict["aps"] as? [String: Any])?["badge"] as? Int {
                NotificationsBadgesManager.shared.set(number: badgeCount)
            }
        default:
            break
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationsBadgesManager.shared.set(number: application.applicationIconBadgeNumber)
    }

//    @available(iOS 8.0, *)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("\(String(describing: userActivity.webpageURL?.absoluteString))")
            if let url = userActivity.webpageURL {
                handleOpenedFromDeepLink(url)
                return true
            }
        }
        return false
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
            // Auth token
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: self, userInfo: ["code": code])
        } else if let queryDict = url.getKeyVals(), let error = queryDict["error"], error == "social_signup_with_existing_email" {
            // Auth redirect with registered email
            let email = (queryDict["email"] ?? "").removingPercentEncoding
            if let topViewController = ControllerHelper.getTopViewController() as? AuthNavigationViewController {
                topViewController.route(from: .social, to: .email(email: email))
            }
        } else {
            // Other actions
            handleOpenedFromDeepLink(url)
        }
        return true
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("completed background task with id: \(identifier)")
        completionHandler()
    }

    func applicationWillTerminate(_ application: UIApplication) {
//        CoreDataHelper.instance.deleteAllPending()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

//    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
//        
//        
//        if let c = window?.rootViewController?.presentedViewController?.classForCoder  {
//            if c != UITabBarController.classForCoder() && c != SignInViewController.classForCoder() && c != UIAlertController.classForCoder() {
//                print("class -> \(c)")
//                return UIInterfaceOrientationMask.Landscape
//            }
//        }
//        return UIInterfaceOrientationMask.Portrait
//    }

    fileprivate func setVideoTestRootController() {
        let rootController = ControllerHelper.instantiateViewController(identifier: "PlayerTestViewController", storyboardName: "PlayerTestStoryboard")
        if self.window != nil {
            self.window!.rootViewController = rootController
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
