//
//  AnalyticsHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Amplitude
import Firebase
import FirebaseCore
import UIKit
import AppMetricaCore

final class AnalyticsHelper {
    static var sharedHelper = AnalyticsHelper()

    func setupAnalytics() {
        FirebaseApp.configure()

        if let configuration = AppMetricaConfiguration(apiKey: Tokens.shared.appMetricaToken) {
            AppMetrica.activate(with: configuration)
        } else {
            #if DEBUG
            print("AnalyticsHelper :: failed to initialize AppMetrica")
            #endif
        }

        Amplitude.instance().initializeApiKey(Tokens.shared.amplitudeToken)
    }
}
