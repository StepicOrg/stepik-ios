//
//  AppDelegate.swift
//  StepicAdaptiveCourse
//
//  Created by Vladislav Kiryukhin on 23.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Mixpanel
import Fabric
import Crashlytics
import PromiseKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // We should store link to actions to prevent deallocating
    var actions: AdaptiveUserActions?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        AnalyticsHelper.sharedHelper.setupAnalytics()

        if !DefaultsContainer.launch.didLaunch {
            AnalyticsReporter.reportEvent(AnalyticsEvents.AdaptiveApp.firstOpen, parameters: nil)
            DefaultsContainer.launch.didLaunch = true
        }

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        LocalNotificationsHelper.registerNotifications()

        if let launchNotification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
            if let userInfo = launchNotification.userInfo as? [String: String], let notificationType = userInfo["type"] {
                AnalyticsReporter.reportEvent(AnalyticsEvents.AdaptiveApp.localNotification, parameters: ["type": notificationType])
            }
        }

        launchViewController()

        return true
    }

    func launchViewController() {
        let supportedCourses = StepicApplicationsInfo.adaptiveSupportedCourses

        var startViewController: UIViewController!

        actions = AdaptiveUserActions(coursesAPI: CoursesAPI(), authAPI: AuthAPI(), stepicsAPI: StepicsAPI(), profilesAPI: ProfilesAPI(), enrollmentsAPI: EnrollmentsAPI(), adaptiveCoursesInfoAPI: AdaptiveCoursesInfoAPI(), defaultsStorageManager: DefaultsStorageManager())

        guard let actions = actions else {
            return
        }

        if supportedCourses.count == 1 {
            // One course -> skip course select
            guard let courseId = supportedCourses.first else {
                return
            }

            guard let initialViewController = ControllerHelper.instantiateViewController(identifier: "AdaptiveCardsSteps", storyboardName: "AdaptiveMain") as? AdaptiveCardsStepsViewController else {
                return
            }

            // Init achievements
            // Use shared object to get access from view (cause we don't have a router layer) and have only one instance per app
            let rating = AdaptiveRatingManager(courseId: courseId).rating
            let streak = AdaptiveRatingManager(courseId: courseId).streak
            // Migration from old version
            let isOnboardingPassed = AdaptiveStorageManager.shared.isAdaptiveOnboardingPassed || DefaultsStorageManager.shared.isRatingOnboardingFinished
            let achievementsManager = AchievementManager.createAndRegisterAchievements(currentRating: rating, currentStreak: streak, currentLevel: AdaptiveRatingHelper.getLevel(for: rating), isOnboardingPassed: isOnboardingPassed)
            AchievementManager.shared = achievementsManager

            let presenter = AdaptiveCardsStepsPresenter(stepsAPI: StepsAPI(), lessonsAPI: LessonsAPI(), recommendationsAPI: RecommendationsAPI(), unitsAPI: UnitsAPI(), viewsAPI: ViewsAPI(), ratingsAPI: AdaptiveRatingsAPI(), ratingManager: AdaptiveRatingManager(courseId: courseId), statsManager: AdaptiveStatsManager(courseId: courseId), storageManager: AdaptiveStorageManager(), achievementsManager: achievementsManager, defaultsStorageManager: DefaultsStorageManager(), lastViewedUpdater: LocalProgressLastViewedUpdater(), view: initialViewController)

            presenter.initialActions = { completion, failure in
                checkToken().then { () -> Promise<Void> in
                    if !AuthInfo.shared.isAuthorized {
                        return actions.registerNewUser()
                    } else {
                        return Promise(value: ())
                    }
                }.then { _ -> Promise<Course> in
                    actions.loadCourseAndJoin(courseId: courseId)
                }.then { course -> Void in
                    completion?(course)
                }.catch { error in
                    failure?(error)
                }
            }

            initialViewController.presenter = presenter
            initialViewController.isBackActionAllowed = false
            startViewController = initialViewController
        } else if supportedCourses.count > 1 {
            // Multiple courses -> present course select
            guard let initialViewController = ControllerHelper.instantiateViewController(identifier: "CourseSelect", storyboardName: "AdaptiveMain") as? UINavigationController else {
                return
            }

            guard let selectController = initialViewController.childViewControllers.first as? AdaptiveCourseSelectViewController else {
                return
            }

            let presenter = AdaptiveCourseSelectPresenter(defaultsStorageManager: DefaultsStorageManager(), view: selectController)
            presenter.initialActions = { completion, failure in
                checkToken().then { () -> Promise<Void> in
                    if !AuthInfo.shared.isAuthorized {
                        return actions.registerNewUser()
                    } else {
                        return Promise(value: ())
                    }
                }.then { _ -> Promise<([Course], [AdaptiveCourseInfo])> in
                    var locale = String(Locale.preferredLanguages.first?.split(separator: "-").first ?? "en")
                    if !Bundle.main.localizations.contains(locale) {
                        locale = "en"
                    }

                    return when(fulfilled: actions.loadCourses(ids: supportedCourses), actions.loadAdaptiveCoursesInfo(locale: locale))
                }.then { courses, adaptiveCoursesInfo in
                    completion?((courses, adaptiveCoursesInfo))
                }.catch { error -> Void in
                    failure?(error)
                }
            }
            selectController.presenter = presenter
            startViewController = initialViewController
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = startViewController
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        LocalNotificationsHelper.schedule(notification: .tomorrow)
        LocalNotificationsHelper.schedule(notification: .weekly)
    }

    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let userInfo = notification.userInfo as? [String: String], let notificationType = userInfo["type"] {
            AnalyticsReporter.reportEvent(AnalyticsEvents.AdaptiveApp.localNotification, parameters: ["type": notificationType])
        }
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
        if let code = Parser.sharedParser.codeFromURL(url) {
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: "ReceivedAuthorizationCodeNotification"), object: self, userInfo: ["code": code])
        } else {
            print("deep link somehow opened StepicAdaptiveCourse")
        }
        return true
    }

}
