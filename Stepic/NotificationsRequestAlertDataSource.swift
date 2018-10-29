//
//  NotificationsRequestAlertDataSource.swift
//  Stepic
//
//  Created by Ivan Magda on 29/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class NotificationsRequestAlertDataSource: NotificationsRequestAlertDataSourceProtocol {
    var positiveAction: (() -> Void)?
    var negativeAction: (() -> Void)?

    func alert(
        for alertType: NotificationsRegistrationServiceAlertType,
        in context: NotificationRequestAlertContext
    ) -> UIViewController {
        switch alertType {
        case .permission:
            let alert = NotificationRequestAlertViewController(context: context)
            alert.yesAction = self.positiveAction
            alert.noAction = self.negativeAction

            return alert
        case .settings:
            let alert = UIAlertController(
                title: NSLocalizedString("DeniedNotificationsDefaultAlertTitle", comment: ""),
                message: NSLocalizedString("DeniedNotificationsDefaultAlertMessage", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("Settings", comment: ""),
                    style: .default,
                    handler: { _ in
                        self.positiveAction?()
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                            UIApplication.shared.openURL(settingsURL)
                        }
                    }
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("OK", comment: ""),
                    style: .default,
                    handler: { _ in
                        self.negativeAction?()
                    }
                )
            )

            return alert
        }
    }
}
