//
//  NotificationsRequestAlertPresenter.swift
//  Stepic
//
//  Created by Ivan Magda on 29/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

final class NotificationsRequestAlertPresenter: NotificationsRegistrationPresentationServiceProtocol {
    var onPositiveCallback: (() -> Void)?
    var onCancelCallback: (() -> Void)?

    private let context: NotificationRequestAlertContext
    private let presentationType: PresentationType
    private let dataSource: NotificationsRequestAlertDataSource
    private let presentAlertIfRegistered: Bool

    private lazy var presentr: Presentr = {
        let presentr = Presentr(presentationType: self.presentationType)
        presentr.roundCorners = true
        return presentr
    }()

    init(
        context: NotificationRequestAlertContext = .default,
        presentationType: PresentationType = .dynamic(center: .center),
        dataSource: NotificationsRequestAlertDataSource = CommonNotificationsRequestAlertDataSource(),
        presentAlertIfRegistered: Bool = false
    ) {
        self.context = context
        self.presentationType = presentationType
        self.dataSource = dataSource
        self.presentAlertIfRegistered = presentAlertIfRegistered
    }

    func presentAlert(
        for alertType: NotificationsRegistrationServiceAlertType,
        inController controller: UIViewController
    ) {
        self.dataSource.positiveAction = self.onPositiveCallback
        self.dataSource.negativeAction = self.onCancelCallback

        if self.presentAlertIfRegistered {
            self.present(alertType: alertType, controller: controller)
        } else {
            NotificationPermissionStatus.current.done { [weak self] status in
                if !status.isRegistered {
                    self?.present(alertType: alertType, controller: controller)
                }
            }
        }
    }

    private func present(
        alertType: NotificationsRegistrationServiceAlertType,
        controller: UIViewController
    ) {
        switch alertType {
        case .permission:
            let alert = self.dataSource.alert(for: .permission, in: self.context)
            controller.customPresentViewController(
                self.presentr,
                viewController: alert,
                animated: true
            )
        case .settings:
            controller.present(
                self.dataSource.alert(for: .settings, in: self.context),
                animated: true
            )
        }
    }
}
