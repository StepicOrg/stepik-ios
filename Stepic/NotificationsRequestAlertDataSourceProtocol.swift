//
//  NotificationsRequestAlertDataSourceProtocol.swift
//  Stepic
//
//  Created by Ivan Magda on 29/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol NotificationsRequestAlertDataSourceProtocol: class {
    var positiveAction: (() -> Void)? { get set }
    var negativeAction: (() -> Void)? { get set }

    func alert(
        for alertType: NotificationsRegistrationServiceAlertType,
        in context: NotificationRequestAlertContext
    ) -> UIViewController
}
