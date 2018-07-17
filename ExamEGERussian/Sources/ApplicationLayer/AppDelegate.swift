//
//  AppDelegate.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

// MARK: AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Instance Properties

    var window: UIWindow?

    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            fatalError("Could not instantiate window")
        }

        let serviceFactory = ServiceFactoryImpl(
            authAPI: AuthAPI(),
            stepicsAPI: StepicsAPI(),
            profilesAPI: ProfilesAPI(),
            notificationStatusesAPI: NotificationStatusesAPI()
        )
        let assemblyFactory = AssemblyFactoryImpl(serviceFactory: serviceFactory)

        guard let router = assemblyFactory.applicationAssembly().module().router else {
            fatalError("Could not instantiate router")
        }

        window.rootViewController = router.rootViewController
        window.makeKeyAndVisible()
        router.window = window

        return true
    }

}
