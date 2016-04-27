//
//  VersionUpdateAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

/*
 Constructs alert controller 
 */
class VersionUpdateAlertConstructor: NSObject {
    private override init() {}
    static let sharedConstructor = VersionUpdateAlertConstructor()
    
    func getUpdateAlertController(updateUrl url: NSURL, addNeverAskAction: Bool) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("UpdateAvailable", comment: ""), message: NSLocalizedString("AppUpdateMessage", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .Default, handler: {
            action in
            UIApplication.sharedApplication().openURL(url)
            UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = NSDate().timeIntervalSince1970
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .Cancel, handler: {
            action in
            UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = NSDate().timeIntervalSince1970
        }))
        
        if addNeverAskAction {
            alert.addAction(UIAlertAction(title: NSLocalizedString("NeverAsk", comment: ""), style: .Destructive, handler: {
                action in
                UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = NSDate().timeIntervalSince1970
                UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks = false
            }))
        }
        
        return alert
    }
    
    func getNoUpdateAvailableAlertController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("NoUpdateAvailable", comment: ""), message: NSLocalizedString("NoAppUpdateMessage", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            action in
            UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = NSDate().timeIntervalSince1970
        }))
                
        return alert
    }
    
}
