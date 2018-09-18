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

        ThirdPartiesConfigurator().configure()

        let serviceFactory = ServiceFactoryBuilder().build()
        let assemblyFactory = AssemblyFactoryBuilder(serviceFactory: serviceFactory).build()

        guard let router = assemblyFactory.applicationAssembly.module().router else {
            fatalError("Could't initialize router")
        }
        router.start(window)

        // Initializes a webview at the start so webview startup later on isn't so slow.
        _ = WKWebView()

        let launchContainer = LaunchDefaultsContainer()
        if !launchContainer.didLaunch {
            launchContainer.didLaunch = true
            AmplitudeAnalyticsEvents.Launch.firstTime.send()
        }
        AmplitudeAnalyticsEvents.Launch.sessionStart.send()

        return true
    }
}
