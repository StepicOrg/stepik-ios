//
//  AppDelegate.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            fatalError("Could't initialize window")
        }

        let serviceFactory = ServiceFactoryBuilder().build()
        let assemblyFactory = AssemblyFactoryBuilder(serviceFactory: serviceFactory).build()

        guard let _ = assemblyFactory.applicationAssembly.makeModule(window: window).router else {
            fatalError("Could't initialize router")
        }

        AppLaunchingCommandsBuilder()
            .build()
            .forEach {
                $0.execute()
            }

        window.makeKeyAndVisible()

        return true
    }
}
