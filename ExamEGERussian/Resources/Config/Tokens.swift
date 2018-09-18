//
//  Tokens.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/09/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class Tokens {
    private(set) var amplitudeToken = ""

    static let shared = Tokens()

    private convenience init() {
        self.init(plist: "Tokens")!
    }

    private init(amplitudeToken: String) {
        self.amplitudeToken = amplitudeToken
    }

    private convenience init?(plist: String) {
        let bundle = Bundle(for: Tokens.self)
        guard let path = bundle.path(forResource: plist, ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let amplitude = dict["Amplitude"] as? String else {
            return nil
        }
        self.init(amplitudeToken: amplitude)
    }

}
