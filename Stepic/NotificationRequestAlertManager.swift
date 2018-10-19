//
//  NotificationRequestAlertManager.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

class NotificationRequestAlertManager: AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController) {
        controller.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
    }

    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .dynamic(center: .center))
        presenter.roundCorners = true
        return presenter
    }()

    func construct(context: NotificationRequestAlertContext) -> NotificationRequestAlertViewController {
        let alert = NotificationRequestAlertViewController(nibName: "NotificationRequestAlertViewController", bundle: nil)
        alert.context = context
        alert.yesAction = {
            NotificationsRegistrationService().register(forceToRequestAuthorization: true)
        }
        alert.noAction = {}
        return alert
    }
}
