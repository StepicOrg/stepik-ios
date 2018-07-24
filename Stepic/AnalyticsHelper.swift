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
import YandexMobileMetrica
import Crashlytics
import Amplitude_iOS
import AppsFlyerLib

class AnalyticsHelper {
    static var sharedHelper = AnalyticsHelper()

    func setupAnalytics() {
        Fabric.with([Crashlytics.self])

        FirebaseApp.configure()

        if let config = YMMYandexMetricaConfiguration(apiKey: Tokens.shared.appMetricaToken) {
            YMMYandexMetrica.activate(with: config)
        }

        Amplitude.instance().initializeApiKey(Tokens.shared.amplitudeToken)

        AppsFlyerTracker.shared().appsFlyerDevKey = Tokens.shared.appsFlyerDevKey
        AppsFlyerTracker.shared().appleAppID = "\(Tokens.shared.firebaseId)"
    }
}
