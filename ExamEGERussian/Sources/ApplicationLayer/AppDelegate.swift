//
//  AppDelegate.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else {
            fatalError("Could't initialize window")
        }

        window.tintColor = UIColor(hex: 0x007AFF)

        ThirdPartiesConfigurator().configure()

        let serviceFactory = ServiceFactoryBuilder().build()
        let assemblyFactory = AssemblyFactoryBuilder(serviceFactory: serviceFactory).build()

        guard let _ = assemblyFactory.applicationAssembly.makeModule(window: window).router else {
            fatalError("Could't initialize router")
        }

        // Initializes a webview at the start so webview startup later on isn't so slow.
        _ = WKWebView()

        let launchContainer = LaunchDefaultsContainer()
        if !launchContainer.didLaunch {
            launchContainer.didLaunch = true
            AmplitudeAnalyticsEvents.Launch.firstTime.send()
        }
        AmplitudeAnalyticsEvents.Launch.sessionStart().send()

        window.makeKeyAndVisible()

        return true
    }
}
