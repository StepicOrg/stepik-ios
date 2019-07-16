//
//  AppDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import FBSDKCoreKit
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import IQKeyboardManagerSwift
import MediaPlayer
import Presentr
import PromiseKit
import SVProgressHUD
import UIKit
import VK_ios_sdk
import YandexMobileMetrica

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let userNotificationsCenterDelegate = UserNotificationsCenterDelegate()
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService()
    private let notificationsService = NotificationsService()
    private let branchService = BranchService(deepLinkRoutingService: DeepLinkRoutingService())
    private let notificationPermissionStatusSettingsObserver = NotificationPermissionStatusSettingsObserver()
    private let alamofireRequestsLogger = AlamofireRequestsLogger()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Initializing the App

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        AnalyticsHelper.sharedHelper.setupAnalytics()
        AnalyticsUserProperties.shared.setApplicationID(id: Bundle.main.bundleIdentifier!)
        AnalyticsUserProperties.shared.updateUserID()

        NotificationsBadgesManager.shared.setup()

        RemoteConfig.shared.setup()

        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)

        ConnectionHelper.shared.instantiate()
        self.alamofireRequestsLogger.startIfDebug()

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

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 24
        IQKeyboardManager.shared.enableAutoToolbar = false

        if !DefaultsContainer.launch.didLaunch {
            DefaultsContainer.launch.initStartVersion()
            ActiveSplitTestsContainer.setActiveTestsGroups()
            AnalyticsUserProperties.shared.setPushPermissionStatus(.notDetermined)
            AnalyticsReporter.reportEvent(AnalyticsEvents.App.firstLaunch, parameters: nil)
            AmplitudeAnalyticsEvents.Launch.firstTime.send()
        }

        if StepicApplicationsInfo.inAppUpdatesAvailable {
            self.checkForUpdates()
        }

        self.notificationsRegistrationService.renewDeviceToken()
        LocalNotificationsMigrator().migrateIfNeeded()
        self.notificationsService.handleLaunchOptions(launchOptions)
        self.userNotificationsCenterDelegate.attachNotificationDelegate()
        self.notificationPermissionStatusSettingsObserver.observe()

        self.checkNotificationsCount()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didChangeOrientation),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        self.didChangeOrientation()

        self.branchService.setup(launchOptions: launchOptions)

        return true
    }

    // MARK: - Responding to App State Changes and System Events

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.notificationsRegistrationService.renewDeviceToken()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationsBadgesManager.shared.set(number: application.applicationIconBadgeNumber)
        self.notificationsService.removeRetentionNotifications()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.notificationsService.scheduleRetentionNotifications()
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

    // MARK: - Handling Notifications -

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        self.notificationsRegistrationService.handleDeviceToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        self.notificationsRegistrationService.handleRegistrationError(error)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) {
        self.notificationsService.handleRemoteNotification(with: userInfo)
    }

    @available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework")
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        self.notificationsService.handleLocalNotification(with: notification.userInfo)
    }

    func application(
        _ application: UIApplication,
        didRegister notificationSettings: UIUserNotificationSettings
    ) {
        self.notificationsRegistrationService.handleRegisteredNotificationSettings(notificationSettings)
    }

    // MARK: Private Helpers

    @objc
    private func didReceiveRegistrationToken(_ notification: Foundation.Notification) {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        InstanceID.instanceID().instanceID { [weak self] (result, error) in
            if let error = error {
                print("Error fetching Firebase remote instance ID: \(error)")
            } else if let result = result {
                self?.notificationsRegistrationService.registerDevice(result.token)
            }
        }
    }

    // MARK: - Continuing User Activity and Handling Quick Actions

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("\(String(describing: userActivity.webpageURL?.absoluteString))")
            if let url = userActivity.webpageURL {
                if branchService.canOpenWithBranch(url: url) {
                    branchService.continueUserActivity(userActivity)
                } else {
                    self.handleOpenedFromDeepLink(url)
                }
                return true
            }
        }
        return false
    }

    // MARK: - Opening a URL-Specified Resource -

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("opened app via url \(url.absoluteString)")

        if let sourceApplication = options[.sourceApplication] as? String,
           VKSdk.processOpen(url, fromApplication: sourceApplication) {
            return true
        }
        if FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        if url.scheme == "vk\(StepicApplicationsInfo.SocialInfo.AppIds.vk)"
               || url.scheme == "fb\(StepicApplicationsInfo.SocialInfo.AppIds.facebook)" {
            return true
        }

        if let code = Parser.sharedParser.codeFromURL(url) {
            // Auth token
            NotificationCenter.default.post(
                name: Foundation.Notification.Name(rawValue: "ReceivedAuthorizationCodeNotification"),
                object: self,
                userInfo: ["code": code]
            )
        } else if let queryDict = url.getKeyVals(),
                  let error = queryDict["error"], error == "social_signup_with_existing_email" {
            // Auth redirect with registered email
            let email = (queryDict["email"] ?? "").removingPercentEncoding
            if let topViewController = ControllerHelper.getTopViewController() as? AuthNavigationViewController {
                topViewController.route(from: .social, to: .email(email: email))
            }
        } else {
            if branchService.canOpenWithBranch(url: url) {
                branchService.openURL(app: app, open: url, options: options)
            } else {
                // Other actions
                self.handleOpenedFromDeepLink(url)
            }
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

            let alert = VersionUpdateAlertConstructor.sharedConstructor.getUpdateAlertController(
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
}
