//
//  AnalyticsHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Fabric
import Firebase
import Mixpanel
import YandexMobileMetrica
import Crashlytics

class AnalyticsHelper: NSObject {
    static var sharedHelper = AnalyticsHelper()
    fileprivate override init() {super.init()}

    func setupAnalytics() {
        Fabric.with([Crashlytics.self])
        FIRApp.configure()

        Mixpanel.initialize(token: Tokens.shared.mixpanelToken)

        YMMYandexMetrica.activate(withApiKey: Tokens.shared.appMetricaToken)
    }
}
