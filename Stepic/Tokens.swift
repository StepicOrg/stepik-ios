//
//  Tokens.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class Tokens {

    var amplitudeToken: String = ""
    var appMetricaToken: String = ""
    var firebaseId: UInt = 0

    static let shared = Tokens()

    private convenience init() {
        self.init(plist: "Tokens")!
    }

    private init(amplitudeToken: String, appMetricaToken: String, firebaseId: UInt) {
        self.amplitudeToken = amplitudeToken
        self.appMetricaToken = appMetricaToken
        self.firebaseId = firebaseId
    }

    private convenience init?(plist: String) {
        let bundle = Bundle(for: type(of: self) as AnyClass)
        guard let path = bundle.path(forResource: plist, ofType: "plist") else {
            return nil
        }
        guard let dic = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return nil
        }
        guard let amplitude = dic["Amplitude"] as? String,
            let appmetrica = dic["AppMetrica"] as? String,
            let firebase = dic["FirebaseAppID"] as? UInt else {
            return nil
        }
        self.init(amplitudeToken: amplitude, appMetricaToken: appmetrica, firebaseId: firebase)
    }

}
