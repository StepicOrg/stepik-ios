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
class UpdateChecker: NSObject {
    private override init() {}
    static let sharedChecker = UpdateChecker()
    
    private func isCheckNeeded() -> Bool {
        
        let lastUpdate = UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime
        
        let isMoreThanDayBetweenChecks = (NSDate().timeIntervalSince1970 - lastUpdate) > 86400
        
        return UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks && isMoreThanDayBetweenChecks
    }
    
    func checkForUpdatesIfNeeded(needUpdateHandler: Version? -> Void, error errorHandler: NSError -> Void) {
        if isCheckNeeded() {
            RemoteVersionManager.sharedManager.checkRemoteVersionChange(needUpdateHandler: needUpdateHandler, error: errorHandler)
        }
    }
}
