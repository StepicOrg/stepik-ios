//
//  AppDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

//import FBSDKCoreKit
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn
import IQKeyboardManagerSwift
import MediaPlayer
import Presentr
import PromiseKit
import SVProgressHUD
import UIKit
import VK_ios_sdk

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    private lazy var userNotificationsCenterDelegate = UserNotificationsCenterDelegate()
    private lazy var notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService()
    private lazy var notificationsService = NotificationsService()
    private lazy var notificationPermissionStatusSettingsObserver = NotificationPermissionStatusSettingsObserver()
    private lazy var branchService = BranchService()
    private lazy var coursePurchaseReminder: CoursePurchaseReminderProtocol = CoursePurchaseReminder.default
    private lazy var spotlightContinueUserActivityService: SpotlightContinueUserActivityServiceProtocol = SpotlightContinueUserActivityService()
    private lazy var applicationShortcutService: ApplicationShortcutServiceProtocol = ApplicationShortcutService()
    private lazy var userCoursesObserver: UserCoursesObserverProtocol = UserCoursesObserver()
    private lazy var visitedCoursesCleaner: VisitedCoursesCleanerProtocol = VisitedCoursesCleaner()
    private lazy var analyticsStorageManager: AnalyticsStorageManagerProtocol = AnalyticsStorageManager.default
    private lazy var analytics: Analytics = StepikAnalytics.shared

    private lazy var siriShortcutsContinueUserActivityService: SiriShortcutsContinueUserActivityServiceProtocol = SiriShortcutsContinueUserActivityService()

    private lazy var widgetService = WidgetService()

    private var applicationDidBecomeActiveAfterLaunch = true

    // MARK: - Initializing the App

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FLEXManager.setup()

        AnalyticsHelper.sharedHelper.setupAnalytics()
        AnalyticsUserProperties.shared.setApplicationID(id: Bundle.main.bundleIdentifier!)
        AnalyticsUserProperties.shared.updateUserID()
        AnalyticsUserProperties.shared.updateIsDarkModeEnabled()
        AnalyticsUserProperties.shared.updateAccessibilityFontScale()
        AnalyticsUserProperties.shared.updateAccessibilityIsVoiceOverRunning()

        NotificationsBadgesManager.shared.setup()

        RemoteConfig.shared.setup()
        RemoteConfig.shared.loadingDoneCallback = {
            ApplicationThemeService().registerDefaultTheme()
        }

        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light)
        SVProgressHUD.setHapticsEnabled(true)

        if !AudioManager.shared.initAudioSession() {
            print("Could not initialize audio session")
        }

//        ApplicationDelegate.shared.application(
//            application,
//            didFinishLaunchingWithOptions: launchOptions
//        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.messagingRegistrationTokenDidRefresh),
            name: .MessagingRegistrationTokenRefreshed,
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
            AnalyticsUserProperties.shared.setPushPermissionStatus(.notDetermined)
            self.analytics.send(.applicationDidLaunchFirstTime)
        }
        ActiveSplitTestsContainer.setActiveTestsGroups()

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

        ApplicationThemeService().registerDefaultTheme()

        IAPService.shared.startObservingPayments()

        // If app launched using a quick action, perform the requested quick action and return a value of false
        // to prevent call the application:performActionForShortcutItem:completionHandler: method.
        if self.applicationShortcutService.handleLaunchOptions(launchOptions) {
            return false
        }

        return true
    }

    // MARK: - Responding to App Life-Cycle Events

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.notificationsRegistrationService.renewDeviceToken()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.analytics.send(.applicationDidBecomeActive)

        NotificationsBadgesManager.shared.set(number: application.applicationIconBadgeNumber)

        self.notificationsService.removeRetentionLocalNotifications()
        self.coursePurchaseReminder.updateAllPurchaseNotifications()

        self.userCoursesObserver.startObserving()
        self.visitedCoursesCleaner.addObserves()

        IAPService.shared.prefetchProducts()

        if #available(iOS 14.0, *) {
            self.widgetService.startIndexingContent(force: self.applicationDidBecomeActiveAfterLaunch)

            let widgetAddedEvent = AmplitudeAnalyticsEvent.homeScreenWidgetAdded(
                size: self.widgetService.getLastWidgetSize()
            )
            if self.widgetService.getIsWidgetAdded() && !self.analyticsStorageManager.didSend(widgetAddedEvent) {
                self.analytics.send(widgetAddedEvent)
                self.analyticsStorageManager.send(widgetAddedEvent)
            }
        }

        self.applicationDidBecomeActiveAfterLaunch = false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.notificationsService.scheduleRetentionLocalNotifications()
        self.userCoursesObserver.stopObserving()
        self.visitedCoursesCleaner.removeObservers()

        if #available(iOS 14.0, *) {
            self.widgetService.stopIndexingContent()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        IAPService.shared.stopObservingPayments()
    }

    // MARK: - Responding to Environment Changes

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        CoreDataHelper.shared.context.refreshAllObjects()
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

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        self.notificationsService.handleLocalNotification(with: notification.userInfo)
    }

    // MARK: Private Helpers

    @objc
    private func messagingRegistrationTokenDidRefresh() {
        guard AuthInfo.shared.isAuthorized else {
            return
        }

        Messaging.messaging().token { [weak self] (token, error) in
            if let error = error {
                print("Error fetching FCM token: \(error)")
            } else if let token = token {
                self?.notificationsRegistrationService.registerDevice(token)
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
                if self.branchService.canOpenWithBranch(url: url) {
                    self.branchService.continueUserActivity(userActivity)
                } else {
                    self.handleOpenedFromDeepLink(url)
                }
                return true
            }
        }

        if self.siriShortcutsContinueUserActivityService.continueUserActivity(userActivity) {
            return true
        }
        if self.spotlightContinueUserActivityService.continueUserActivity(userActivity) {
            return true
        }

        return false
    }

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(self.applicationShortcutService.handleShortcutItem(shortcutItem))
    }

    // MARK: - Opening a URL-Specified Resource -

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        print("opened app via url \(url.absoluteString)")

        let sourceApplicationOrNil = options[.sourceApplication] as? String

        if VKSdk.processOpen(url, fromApplication: sourceApplicationOrNil) {
            return true
        }
//        if ApplicationDelegate.shared.application(app, open: url, options: options) {
//            return true
//        }
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        if url.scheme == "vk\(StepikApplicationsInfo.SocialInfo.AppIds.vk)"
            || url.scheme == "fb\(StepikApplicationsInfo.SocialInfo.AppIds.facebook)" {
            return true
        }

        if let code = Parser.codeFromURL(url) {
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
            if self.branchService.canOpenWithBranch(url: url) {
                self.branchService.openURL(app: app, open: url, options: options)
            } else if #available(iOS 14.0, *), self.widgetService.canOpenRouteURL(url) {
                self.widgetService.openRouteURL(url)
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

    private func checkNotificationsCount() {
        guard AuthInfo.shared.isAuthorized else {
            return NotificationsBadgesManager.shared.set(number: 0)
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
