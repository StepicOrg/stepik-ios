//
//  NotificationsRequestAlertPresenter.swift
//  Stepic
//
//  Created by Ivan Magda on 29/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

final class NotificationsRequestAlertPresenter: NotificationsRegistrationServicePresenterProtocol {
    var onPositiveCallback: (() -> Void)?
    var onCancelCallback: (() -> Void)?

    private let context: NotificationRequestAlertContext
    private let presentationType: PresentationType
    private let dataSource: NotificationsRequestAlertDataSourceProtocol
    private let presentAlertIfRegistered: Bool

    init(
        context: NotificationRequestAlertContext = .default,
        presentationType: PresentationType = .dynamic(center: .center),
        dataSource: NotificationsRequestAlertDataSourceProtocol = NotificationsRequestAlertDataSource(),
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
            NotificationPermissionStatus.current().done { [weak self] status in
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
            let presenter = Presentr(presentationType: self.presentationType)
            presenter.roundCorners = true

            let alert = self.dataSource.alert(for: .permission, in: self.context)
            controller.customPresentViewController(
                presenter,
                viewController: alert,
                animated: true
            )

            NotificationSuggestionManager().didShowAlert(context: self.context)
        case .settings:
            controller.present(
                self.dataSource.alert(for: .settings, in: self.context),
                animated: true
            )
        }
    }
}
