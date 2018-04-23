//
//  AnalyticsHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Fabric
import FirebaseCore
import Mixpanel
import YandexMobileMetrica
import Crashlytics

#if ENABLE_APPSEE
    import Appsee
#endif

class AnalyticsHelper: NSObject {
    static var sharedHelper = AnalyticsHelper()
    fileprivate override init() {super.init()}

    func setupAnalytics() {
        #if ENABLE_APPSEE
            Fabric.with([Crashlytics.self, Appsee.self])
        #else
            Fabric.with([Crashlytics.self])
        #endif

        FirebaseApp.configure()

        Mixpanel.initialize(token: Tokens.shared.mixpanelToken)

        YMMYandexMetrica.activate(withApiKey: Tokens.shared.appMetricaToken)
    }
}
