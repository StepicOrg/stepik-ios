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
import Google 

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        
        setRootController()
        ConnectionHelper.shared.instantiate()
        if !AudioManager.sharedManager.initAudioSession() {
            print("Could not initialize audio session")
        }
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        gai.logger.logLevel = GAILogLevel.None  // remove before app release
        

//        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//        print(documentsPath)
        return true
    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        print("opened app via url \(url.absoluteString)")
        let codeOpt = Parser.sharedParser.codeFromURL(url)
        if let code = codeOpt {
            NSNotificationCenter.defaultCenter().postNotificationName("ReceivedAuthorizationCodeNotification", object: self, userInfo: ["code": code])
//            let launchController = ControllerHelper.showLaunchController(true)
//            
//            print(self.window?.rootViewController?.classForCoder)
//            launchController.performSegueWithIdentifier("signInSegue", sender: nil)
//            launchController.signInController!.authentificateWithCode(code)
            
        } else {
            print("error while authentificating")
        }
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
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
    
    private func setRootController() {
        if StepicAPI.shared.isAuthorized {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // instantiate your desired ViewController
            let rootController = storyboard.instantiateViewControllerWithIdentifier("MainTabBarController") 
            
            // Because self.window is an optional you should check it's value first and assign your rootViewController
            if self.window != nil {
                self.window!.rootViewController = rootController
            }
        }
    }
    

}

