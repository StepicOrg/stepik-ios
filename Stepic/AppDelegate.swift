//
//  AppDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import MediaPlayer
import FirebaseCore
import FirebaseMessaging
import FirebaseInstanceID
import IQKeyboardManagerSwift
import SVProgressHUD
import VK_ios_sdk
import FBSDKCoreKit
import YandexMobileMetrica
import Presentr
import SwiftyJSON
import PromiseKit
import AppsFlyerLib

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var currentNavigationController: UINavigationController? {
        guard let tabController = window?.rootViewController as? UITabBarController else {
            return nil
        }

        let countViewControllers = tabController.viewControllers?.count ?? 0

        if tabController.selectedIndex < countViewControllers {
            return tabController.viewControllers?[tabController.selectedIndex] as? UINavigationController
        } else {
            return tabController.viewControllers?[0] as? UINavigationController
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Initializing the App

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        AnalyticsHelper.sharedHelper.setupAnalytics()
        AnalyticsUserProperties.shared.setApplicationID(id: Bundle.main.bundleIdentifier!)
        AnalyticsUserProperties.shared.updateUserID()

        WatchSessionManager.sharedManager.startSession()

        NotificationsBadgesManager.shared.setup()

        RemoteConfig.shared.setup()

        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)

        ConnectionHelper.shared.instantiate()

        if !AudioManager.sharedManager.initAudioSession() {
            print("Could not initialize audio session")
        }

        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didReceiveRegistrationToken(_:)),
            name: .InstanceIDTokenRefresh,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didBadgeUpdate(_:)),
            name: .badgeUpdated,
            object: nil
        )

        ExecutionQueues.sharedQueues.setUpQueueObservers()
        ExecutionQueues.sharedQueues.recoverQueuesFromPersistentStore()
        ExecutionQueues.sharedQueues.executeConnectionAvailableQueue()

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        if !DefaultsContainer.launch.didLaunch {
            AnalyticsReporter.reportEvent(AnalyticsEvents.App.firstLaunch, parameters: nil)
            AmplitudeAnalyticsEvents.Launch.firstTime.send()
        }
        AmplitudeAnalyticsEvents.Launch.sessionStart.send()

        if StepicApplicationsInfo.inAppUpdatesAvailable {
            checkForUpdates()
        }

        if AuthInfo.shared.isAuthorized {
            NotificationRegistrator.shared.registerForRemoteNotificationsIfAlreadyAsked()
        }

        // TODO: notification
        if (launchOptions?[.localNotification]) != nil {
            handleLocalNotification()
        }

        // TODO: notification
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            handleRemoteNotification(notification)
        }

        checkNotificationsCount()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didChangeOrientation),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )
        didChangeOrientation()

        return true
    }

    // MARK: - Responding to App State Changes and System Events

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationsBadgesManager.shared.set(number: application.applicationIconBadgeNumber)
        AppsFlyerTracker.shared().trackAppLaunch()
    }

    // MARK: - Downloading Data in the Background

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        print("completed background task with id: \(identifier)")
        completionHandler()
    }

    // MARK: - Handling Remote Notifications -

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        NotificationRegistrator.shared.getGCMRegistrationToken(deviceToken: deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("error while registering to remote notifications")
    }

    // TODO: Notification
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
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
                    self.handleRemoteNotification(notificationDict)
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

    // MARK: Private Helpers

    private func handleLocalNotification() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened)
    }

    private func handleRemoteNotification(_ notificationDict: [String: Any]) {
        guard let reaction = NotificationReactionHandler.handle(with: notificationDict),
              let topController = self.currentNavigationController?.topViewController else {
            return
        }
        reaction(topController)
    }

    @objc
    private func didReceiveRegistrationToken(_ notification: Foundation.Notification) {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching Firebase remote instanse ID: \(error)")
            } else if let result = result {
                NotificationRegistrator.shared.registerDevice(result.token)
            }
        }
    }

    // MARK: - Continuing User Activity and Handling Quick Actions

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([Any]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("\(String(describing: userActivity.webpageURL?.absoluteString))")
            if let url = userActivity.webpageURL {
                handleOpenedFromDeepLink(url)
                return true
            }
        }
        return false
    }

    // MARK: - Opening a URL-Specified Resource -

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplicationOpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        print("opened app via url \(url.absoluteString)")

        if let sourceApplication = options[.sourceApplication] as? String,
            VKSdk.processOpen(url, fromApplication: sourceApplication) {
            return true
        }
        if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        if url.scheme == "vk\(StepicApplicationsInfo.SocialInfo.AppIds.vk)" || url.scheme == "fb\(StepicApplicationsInfo.SocialInfo.AppIds.facebook)" {
            return true
        }

        if let code = Parser.sharedParser.codeFromURL(url) {
            // Auth token
            NotificationCenter.default.post(
                name: Foundation.Notification.Name(rawValue: "ReceivedAuthorizationCodeNotification"),
                object: self,
                userInfo: ["code": code]
            )
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

    // MARK: Private Helpers

    private func handleOpenedFromDeepLink(_ url: URL) {
        let deepLinkRoutingService = DeepLinkRoutingService()
        DispatchQueue.main.async {
            deepLinkRoutingService.route(path: url.absoluteString)
        }
    }

    // MARK: - Private API -

    private func checkForUpdates() {
        UpdateChecker.sharedChecker.checkForUpdatesIfNeeded({ [weak self] newVersion in
            guard let newVersion = newVersion else {
                return
            }

            let alert = VersionUpdateAlertConstructor.sharedConstructor
                .getUpdateAlertController(
                    updateUrl: newVersion.url,
                    addNeverAskAction: true
                )
            UIThread.performUI {
                self?.window?.rootViewController?.present(alert, animated: true)
            }
        }, error: { error in
            print("error while checking for updates: \(error.code) \(error.localizedDescription)")
        })
    }

    private func checkNotificationsCount() {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        ApiDataDownloader.notificationsStatusAPI.retrieve().done { result in
            NotificationsBadgesManager.shared.set(number: result.totalCount)
        }.catch { _ in
            print("notifications: unable to fetch badges count on launch")
            NotificationsBadgesManager.shared.set(number: 0)
        }
    }

    @objc
    private func didBadgeUpdate(_ notification: Foundation.Notification) {
        guard let userInfo = notification.userInfo,
              let value = userInfo["value"] as? Int else {
            return
        }

        UIApplication.shared.applicationIconBadgeNumber = value
    }

    @objc
    private func didChangeOrientation() {
        AnalyticsUserProperties.shared.setScreenOrientation(
            isPortrait: DeviceInfo.current.orientation.interface.isPortrait
        )
    }

    private func setVideoTestRootController() {
        guard let window = window else {
            return
        }

        let rootController = ControllerHelper.instantiateViewController(
            identifier: "PlayerTestViewController",
            storyboardName: "PlayerTestStoryboard"
        )

        window.rootViewController = rootController
    }
}
