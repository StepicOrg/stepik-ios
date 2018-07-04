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
    
    private lazy var rootNavigationManager: RootNavigationManager = {
        return RootNavigationManager(with: self.window, serviceComponents: self.serviceComponents)
    }()
    
    private lazy var serviceComponents: ServiceComponents = {
        return ServiceComponentsAssembly(
            authAPI: AuthAPI(),
            stepicsAPI: StepicsAPI(),
            profilesAPI: ProfilesAPI(),
            defaultsStorageManager: DefaultsStorageManager()
        )
    }()
    
    // MARK: - UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        rootNavigationManager.setup()
        
        return true
    }
    
}
