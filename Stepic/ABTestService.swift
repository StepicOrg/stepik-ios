//
//  ABTestService.swift
//  Stepic
//
//  Created by Ostrenkiy on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol ActiveABTest {
    associatedtype ValueType
    var ID: String { get }
    func value(group: String) -> ValueType?
    var controlValue: ValueType { get }
}

class ABTestService {

    private let defaults = UserDefaults.standard

    init() {}

    func getValue<T: ActiveABTest>(test: T) -> T.ValueType {

        if let resultGroup = RemoteConfig.shared.string(forKey: test.ID + "_result") {
            if !resultGroup.isEmpty {
                defaults.set(resultGroup, forKey: test.ID)
                return test.value(group: resultGroup) ?? test.controlValue
            }
        }

        if let group = defaults.value(forKey: test.ID) as? String {
            return test.value(group: group) ?? test.controlValue
        } else {
            if RemoteConfig.shared.fetchComplete {
                guard
                    let group = RemoteConfig.shared.string(forKey: test.ID),
                    let value = test.value(group: group)
                else {
                    return test.controlValue
                }
                defaults.set(group, forKey: test.ID)
                AnalyticsUserProperties.shared.setAmplitudeProperty(key: test.ID, value: group)
                return value
            } else {
                return test.controlValue
            }
        }
    }
}
