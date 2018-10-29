//
//  StreakNotificationsRequestAlertDataSource.swift
//  Stepic
//
//  Created by Ivan Magda on 29/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class StreakNotificationsRequestAlertDataSource: NotificationsRequestAlertDataSourceProtocol {
    var positiveAction: (() -> Void)?
    var negativeAction: (() -> Void)?

    private let streak: Int

    init(streak: Int) {
        self.streak = streak
    }

    func alert(
        for alertType: NotificationsRegistrationServiceAlertType,
        in context: NotificationRequestAlertContext
    ) -> UIViewController {
        switch alertType {
        case .permission:
            let alert = NotificationRequestAlertViewFactory.make(for: context)
            alert.currentStreak = self.streak
            alert.yesAction = self.positiveAction
            alert.noAction = self.negativeAction

            return alert
        case .settings:
            let alert = UIAlertController(
                title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""),
                message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""),
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("Yes", comment: ""),
                    style: .default,
                    handler: { [weak self] _ in
                        self?.positiveAction?()
                    }
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("No", comment: ""),
                    style: .cancel,
                    handler: { [weak self] _ in
                        self?.negativeAction?()
                    }
                )
            )

            return alert
        }
    }
}
