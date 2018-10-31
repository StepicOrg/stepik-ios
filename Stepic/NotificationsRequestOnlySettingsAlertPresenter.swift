//
//  NotificationsRequestOnlySettingsAlertPresenter.swift
//  Stepic
//
//  Created by Ivan Magda on 29/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class NotificationsRequestOnlySettingsAlertPresenter: NotificationsRegistrationPresentationServiceProtocol {
    var onPositiveCallback: (() -> Void)?
    var onCancelCallback: (() -> Void)?

    private let context: NotificationRequestAlertContext
    private let dataSource: NotificationsRequestAlertDataSource

    init(context: NotificationRequestAlertContext = .default,
         dataSource: NotificationsRequestAlertDataSource = CommonNotificationsRequestAlertDataSource()
    ) {
        self.context = context
        self.dataSource = dataSource
    }

    func presentAlert(
        for alertType: NotificationsRegistrationServiceAlertType,
        inController controller: UIViewController
    ) {
        switch alertType {
        case .permission:
            self.onPositiveCallback?()
        case .settings:
            self.dataSource.positiveAction = self.onPositiveCallback
            self.dataSource.negativeAction = self.onCancelCallback

            controller.present(
                self.dataSource.alert(for: .settings, in: self.context),
                animated: true
            )
        }
    }
}
