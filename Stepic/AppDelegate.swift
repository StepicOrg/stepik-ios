  //
//  AppDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.08.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import MediaPlayer
import Fabric
import Crashlytics
import Firebase 
import FirebaseMessaging
import IQKeyboardManagerSwift
import SVProgressHUD
import MagicalRecord
import VK_ios_sdk
import FBSDKCoreKit
import Mixpanel
import YandexMobileMetrica
import Presentr

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
		
		if #available(iOS 9.0, *) {
			WatchSessionManager.sharedManager.startSession()
		}
        
        MagicalRecord.setupCoreDataStackWithAutoMigratingSqliteStore(at: CoreDataHelper.instance.storeURL as URL)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        
//        setVideoTestRootController()
        ConnectionHelper.shared.instantiate()
        if !AudioManager.sharedManager.initAudioSession() {
            print("Could not initialize audio session")
        }
        
        FIRApp.configure()
        FIRAppIndexing.sharedInstance().registerApp(1064581926)
        
        Mixpanel.initialize(token: "cc80751831012d6a0de6bba73ec2f556")
        AnalyticsReporter.reportMixpanelEvent(AnalyticsEvents.App.opened, parameters: nil)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        YMMYandexMetrica.activate(withApiKey: "fd479031-bdf4-419e-8d8f-6895aab23502")
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.didReceiveRegistrationToken(_:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
        
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
                
        if (launchOptions?[UIApplicationLaunchOptionsKey.localNotification]) != nil  {
            handleLocalNotification()
        }
        
        if let notificationDict = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [NSString: AnyObject] {
            handleNotification(notificationDict)
        }
        
        checkStreaks() 
        
        if !DefaultsContainer.launch.didLaunch {
            AnalyticsReporter.reportEvent(AnalyticsEvents.App.firstLaunch, parameters: nil)
            DefaultsContainer.launch.didLaunch = true
        }
        
        return true
    }

    
    //Streaks presentation
    //TODO: Refactor this into a class
    let streaksPopupPresentr : Presentr = {
        let width = ModalSize.sideMargin(value: 24)
        let height = ModalSize.custom(size: 300.0)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVerticalFromTop
        customPresenter.dismissTransitionType = .coverVerticalFromTop
        customPresenter.roundCorners = true
        customPresenter.backgroundColor = UIColor.black
        customPresenter.backgroundOpacity = 0.5
        return customPresenter
    }()
    
    func presentStreaks(userActivity: UserActivity) {
        
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.LocalNotification.shown, parameters: [
            "current" : userActivity.currentStreak,
            "longest" : userActivity.longestStreak,
            "percentage" : String(format: "%.02f", Double(userActivity.currentStreak)/Double(userActivity.longestStreak))
            ])

        
        guard let nav = currentNavigation else {
            return
        }
        
        let vc = CurrentBestStreakViewController(nibName: "CurrentBestStreakViewController", bundle: nil) as CurrentBestStreakViewController
        
        vc.activity = userActivity
        nav.customPresentViewController(streaksPopupPresentr, viewController: vc, animated: true, completion: nil)
    }
    
    func checkStreaks() {
        func dayLocalizableFor(daysCnt: Int) -> String {
            switch (daysCnt % 10) {
            case 1: return NSLocalizedString("days1", comment: "")
            case 2, 3, 4: return NSLocalizedString("days234", comment: "")
            default: return NSLocalizedString("days567890", comment: "")
            }
        }
        guard let userId = AuthInfo.shared.userId else {
            return
        }
        _ = ApiDataDownloader.userActivities.retrieve(user: userId, success: {
            [weak self]
            userActivity in
            if userActivity.needsToSolveToday {
                let streakText = "\(NSLocalizedString("YouAreSolving", comment: "")) \(userActivity.currentStreak) \(dayLocalizableFor(daysCnt: userActivity.currentStreak)) \(NSLocalizedString("InARow", comment: "")).\n\(NSLocalizedString("SolveToImprove", comment: ""))"
                let subtitleText = "\(NSLocalizedString("TapToLearnAboutStreaks", comment: ""))"
                NotificationAlertConstructor.sharedConstructor.presentStreakNotificationFake(streakText, subtitleText: subtitleText, success: {
                    [weak self] in
                    self?.presentStreaks(userActivity: userActivity)
                })
                AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.LocalNotification.shown, parameters: [
                    "current" : userActivity.currentStreak,
                    "longest" : userActivity.longestStreak,
                    "percentage" : String(format: "%.02f", Double(userActivity.currentStreak)/Double(userActivity.longestStreak))
                    ])
            }
        }, error: {
            error in
        })
    }
    
    
    //Notification handling
    
    func handleLocalNotification() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Streaks.notificationOpened, parameters: nil)
    }
        
    fileprivate func handleNotification(_ notificationDict: [NSString: AnyObject]) {
        if let reaction = NotificationReactionHandler().handleNotificationWithUserInfo(notificationDict), 
            let topController = currentNavigation?.topViewController {
            reaction(topController)
        }
    }
    
    var currentNavigation : UINavigationController? {
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
                    action in
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
        UpdateChecker.sharedChecker.checkForUpdatesIfNeeded(
            {
                newVersion in
                if let version = newVersion {
                    let alert = VersionUpdateAlertConstructor.sharedConstructor.getUpdateAlertController(updateUrl: version.url, addNeverAskAction: true)
                    UIThread.performUI{
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
        
        if let notificationDict = userInfo as? [NSString: AnyObject] {
            if let text = ((notificationDict["aps"] as? [AnyHashable: Any])?["alert"] as? [AnyHashable: Any])?["body"] as? String {
                NotificationAlertConstructor.sharedConstructor.presentNotificationFake(text, success: 
                    {
                        self.handleNotification(notificationDict)
                    }
                )
            }
        }
        print("didReceiveRemoteNotification with userInfo: \(userInfo)")
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
        let codeOpt = Parser.sharedParser.codeFromURL(url)
        if let code = codeOpt {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: self, userInfo: ["code": code])            
        } else {
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
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    }

}

