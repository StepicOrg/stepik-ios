//
// NotificationPermissionStatusDaemon.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-12-12.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

final class NotificationPermissionStatusDaemon {
    private var didTransitionToSettings = false
    private var permissionStatus: NotificationPermissionStatus = .notDetermined

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func setup() {
        self.initPermissionStatus()
        self.addObservers()
    }

    @objc
    private func handleWillEnterForeground() {
        if self.didTransitionToSettings {
            self.didTransitionToSettings = false
            self.handleTransitionFromSettings()
        }
    }

    @objc
    private func handleTransitionToSettings() {
        self.didTransitionToSettings = true
    }

    private func handleTransitionFromSettings() {
        NotificationPermissionStatus.current.done { permissionStatus in
            AnalyticsUserProperties.shared.setPushPermissionStatus(permissionStatus)

            if !self.permissionStatus.isRegistered && permissionStatus.isRegistered {
                AmplitudeAnalyticsEvents.Notifications.preferencesPushPermissionGranted.send()
            }

            self.permissionStatus = permissionStatus
        }
    }

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleWillEnterForeground),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleTransitionToSettings),
            name: .notificationsRegistrationServiceWillOpenSettings,
            object: nil
        )
    }

    private func initPermissionStatus() {
        NotificationPermissionStatus.current.done { permissionStatus in
            self.permissionStatus = permissionStatus
        }
    }
}
