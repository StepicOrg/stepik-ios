//
//  NotificationsRegistrationServiceAlertProvider.swift
//  Stepic
//
//  Created by Ivan Magda on 22/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

protocol NotificationsRegistrationServiceAlertProvider {
    var onPositiveCallback: (() -> Void)? { get set }
    var onCancelCallback: (() -> Void)? { get set }

    func alert(for alertType: NotificationsRegistrationService.AlertType) -> UIViewController

    func presentAlert(
        for type: NotificationsRegistrationService.AlertType,
        inController rootViewController: UIViewController
    )
}

struct DefaultNotificationsRegistrationServiceAlertProvider: NotificationsRegistrationServiceAlertProvider {
    var onPositiveCallback: (() -> Void)?
    var onCancelCallback: (() -> Void)?

    func alert(for alertType: NotificationsRegistrationService.AlertType) -> UIViewController {
        switch alertType {
        case .permission:
            return self.makePermissionAlert()
        case .settings:
            return self.makeSettingsAlert()
        }
    }

    func presentAlert(
        for type: NotificationsRegistrationService.AlertType,
        inController rootViewController: UIViewController
    ) {
        switch type {
        case .permission:
            let presenter = Presentr(presentationType: .dynamic(center: .center))
            presenter.roundCorners = true

            rootViewController.customPresentViewController(
                presenter,
                viewController: self.makePermissionAlert(),
                animated: true
            )
        case .settings:
            rootViewController.present(self.makeSettingsAlert(), animated: true)
        }
    }

    private func makePermissionAlert() -> UIViewController {
        let alertController = NotificationRequestAlertViewController(
            nibName: "NotificationRequestAlertViewController",
            bundle: nil
        )
        alertController.context = .streak
        alertController.yesAction = self.onPositiveCallback
        alertController.noAction = self.onCancelCallback

        alertController.loadViewIfNeeded()
        alertController.titleLabel.text = NSLocalizedString("NotificationRequestDefaultAlertTitle", comment: "")
        alertController.messageLabel.text = NSLocalizedString("NotificationRequestDefaultAlertMessage", comment: "")

        return alertController
    }

    private func makeSettingsAlert() -> UIViewController {
        let alertController = UIAlertController(
            title: NSLocalizedString("DeniedNotificationsDefaultAlertTitle", comment: ""),
            message: NSLocalizedString("DeniedNotificationsDefaultAlertMessage", comment: ""),
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { _ in
                self.onPositiveCallback?()
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
