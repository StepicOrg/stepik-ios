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

    private func handleTransitionFromSettings() {
        NotificationPermissionStatus.current.done { permissionStatus in
            AnalyticsUserProperties.shared.setPushPermissionStatus(permissionStatus)

            if !self.permissionStatus.isRegistered && permissionStatus.isRegistered {
                AmplitudeAnalyticsEvents.Notifications.preferencesPushPermissionGranted.send()
            }

            self.permissionStatus = permissionStatus
        }
    }

    // MARK: Actions

    @objc
    private func onWillEnterForeground() {
        if self.didTransitionToSettings {
            self.didTransitionToSettings = false
            self.handleTransitionFromSettings()
        }
    }

    @objc
    private func onTransitionToSettings() {
        self.didTransitionToSettings = true
    }

    @objc
    private func onPermissionStatusUpdate(_ notification: Foundation.Notification) {
        if let permissionStatus = notification.object as? NotificationPermissionStatus {
            self.permissionStatus = permissionStatus
        }
    }

    // MARK: Setup

    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onWillEnterForeground),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onTransitionToSettings),
            name: .notificationsRegistrationServiceWillOpenSettings,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.onPermissionStatusUpdate(_:)),
            name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
            object: nil
        )
    }

    private func initPermissionStatus() {
        NotificationPermissionStatus.current.done { permissionStatus in
            self.permissionStatus = permissionStatus
        }
    }
}
