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
            coursesAPI: CoursesAPI(),
            enrollmentsAPI: EnrollmentsAPI(),
            lessonsAPI: LessonsAPI(),
            defaultsStorageManager: DefaultsStorageManager.shared
        )
        let assemblyFactory = AssemblyFactoryImpl(
            serviceFactory: serviceFactory,
            knowledgeGraph: KnowledgeGraph()
        )

        guard let router = assemblyFactory.applicationAssembly.module().router else {
            fatalError("Could not instantiate router")
        }
        router.start(window)

        ThirdPartiesConfigurator().configure()

        return true
    }

}
