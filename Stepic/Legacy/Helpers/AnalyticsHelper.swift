//
//  AnalyticsHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Amplitude_iOS
import Firebase
import UIKit
import YandexMobileMetrica

final class AnalyticsHelper {
    static var sharedHelper = AnalyticsHelper()

    func setupAnalytics() {
        FirebaseApp.configure()

        if let config = YMMYandexMetricaConfiguration(apiKey: Tokens.shared.appMetricaToken) {
            YMMYandexMetrica.activate(with: config)
        }

        Amplitude.instance().initializeApiKey(Tokens.shared.amplitudeToken)
    }
}
