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
    fileprivate override init() {}
    static let sharedConstructor = VersionUpdateAlertConstructor()

    func getUpdateAlertController(updateUrl url: URL, addNeverAskAction: Bool) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("UpdateAvailable", comment: ""), message: NSLocalizedString("AppUpdateMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Update", comment: ""), style: .default, handler: {
            _ in
            UIApplication.shared.openURL(url)
            UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = Date().timeIntervalSince1970
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .cancel, handler: {
            _ in
            UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = Date().timeIntervalSince1970
        }))

        if addNeverAskAction {
            alert.addAction(UIAlertAction(title: NSLocalizedString("NeverAsk", comment: ""), style: .destructive, handler: {
                _ in
                UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = Date().timeIntervalSince1970
                UpdatePreferencesContainer.sharedContainer.allowsUpdateChecks = false
            }))
        }

        return alert
    }

    func getNoUpdateAvailableAlertController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("NoUpdateAvailable", comment: ""), message: NSLocalizedString("NoAppUpdateMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            _ in
            UpdatePreferencesContainer.sharedContainer.lastUpdateCheckTime = Date().timeIntervalSince1970
        }))

        return alert
    }

}
