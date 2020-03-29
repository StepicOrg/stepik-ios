//
//  UpdateChecker.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

/*
 This class checks for updates if needed
 */
final class UpdateChecker: NSObject {
    static let shared = UpdateChecker()

    override private init() {}

    func checkForUpdatesIfNeeded(
        _ needUpdateHandler: @escaping (Version?) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) {
        if isCheckNeeded() {
            RemoteVersionManager
                .shared
                .checkRemoteVersionChange(needUpdateHandler: needUpdateHandler, error: errorHandler)
        }
    }

    private func isCheckNeeded() -> Bool {
        let lastUpdate = UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime
        let isMoreThanDayBetweenChecks = (Date().timeIntervalSince1970 - lastUpdate) > 86400
        return UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks && isMoreThanDayBetweenChecks
    }
}
