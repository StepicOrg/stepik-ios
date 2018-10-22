//
//  NotificationsRegistrationServiceAlertProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 22/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol NotificationsRegistrationServiceAlertProvider {
    var onSuccessCallback: (() -> Void)? { get set }
    var onCancelCallback: (() -> Void)? { get set }

    var permission: UIViewController { get }
    var settings: UIViewController { get }
}

struct DefaultNotificationsRegistrationServiceAlertProvider: NotificationsRegistrationServiceAlertProvider {
    var onSuccessCallback: (() -> Void)?

    var onCancelCallback: (() -> Void)?

    var permission: UIViewController {
        let alertController = NotificationRequestAlertViewController(
            nibName: "NotificationRequestAlertViewController",
            bundle: nil
        )
        alertController.context = .streak
        alertController.yesAction = self.onSuccessCallback
        alertController.noAction = self.onCancelCallback

        alertController.loadViewIfNeeded()
        alertController.titleLabel.text = NSLocalizedString("NotificationRequestDefaultAlertTitle", comment: "")
        alertController.messageLabel.text = NSLocalizedString("NotificationRequestDefaultAlertMessage", comment: "")

        return alertController
    }

    var settings: UIViewController {
        let alertController = UIAlertController(
            title: NSLocalizedString("DeniedNotificationsDefaultAlertTitle", comment: ""),
            message: NSLocalizedString("DeniedNotificationsDefaultAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { _ in
                self.onSuccessCallback?()
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(settingsURL)
                }
            })
        )
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { _ in
                self.onCancelCallback?()
            })
        )

        return alertController
    }
}
