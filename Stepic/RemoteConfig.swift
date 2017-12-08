//
//  RemoteConfig.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Firebase

enum RemoteConfigKeys: String {
    case showStreaksNotificationTime = "show_streaks_notification_time"
}

class RemoteConfig {
    private let defaultShowStreaksNotificationTime = ShowStreaksNotificationTime.main

    var loadingDoneCallback: (() -> Void)?
    var fetchComplete: Bool = false

    enum ShowStreaksNotificationTime: String {
        case main = "main"
        case submission = "submission"
    }

    var showStreaksNotificationTime: ShowStreaksNotificationTime {
        guard let configValue = FIRRemoteConfig.remoteConfig().configValue(forKey: RemoteConfigKeys.showStreaksNotificationTime.rawValue).stringValue else {
            return defaultShowStreaksNotificationTime
        }
        return ShowStreaksNotificationTime(rawValue: configValue) ?? defaultShowStreaksNotificationTime
    }

    init() {
        loadDefaultValues()
        fetchCloudValues()
    }

    func setup() {}

    static let sharedConfig = RemoteConfig()

    private func loadDefaultValues() {
        let appDefaults: [String: NSObject] = [
            RemoteConfigKeys.showStreaksNotificationTime.rawValue : defaultShowStreaksNotificationTime.rawValue as NSObject
        ]
        FIRRemoteConfig.remoteConfig().setDefaults(appDefaults)
    }

    private func fetchCloudValues() {
        let fetchDuration: TimeInterval = 0
        activateDebugMode()
        FIRRemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) {
            [weak self]
            _, error in

            guard error == nil else {
                print ("Uh-oh. Got an error fetching remote values \(String(describing: error))")
                return
            }

            FIRRemoteConfig.remoteConfig().activateFetched()

            self?.fetchComplete = true
            self?.loadingDoneCallback?()
        }
    }

    private func activateDebugMode() {
        let debugSettings = FIRRemoteConfigSettings(developerModeEnabled: true)
        FIRRemoteConfig.remoteConfig().configSettings = debugSettings!
    }
}
