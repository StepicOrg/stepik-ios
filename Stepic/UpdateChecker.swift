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
    fileprivate override init() {}
    static let sharedChecker = UpdateChecker()
    
    fileprivate func isCheckNeeded() -> Bool {
        
        let lastUpdate = UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime
        
        let isMoreThanDayBetweenChecks = (Date().timeIntervalSince1970 - lastUpdate) > 86400
        
        return UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks && isMoreThanDayBetweenChecks
    }
    
    func checkForUpdatesIfNeeded(_ needUpdateHandler: (Version?) -> Void, error errorHandler: (NSError) -> Void) {
        if isCheckNeeded() {
            RemoteVersionManager.sharedManager.checkRemoteVersionChange(needUpdateHandler: needUpdateHandler, error: errorHandler)
        }
    }
}
