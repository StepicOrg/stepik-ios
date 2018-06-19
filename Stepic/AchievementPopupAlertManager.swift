//
//  AchievementPopupAlertManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

class AchievementPopupAlertManager: AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController) {
        controller.customPresentViewController(presentr, viewController: alert, animated: true, completion: nil)
    }

    let presentr: Presentr = {
        var presentationType = PresentationType.popup
        if DeviceInfo.current.isPad {
            // For phone screens use default popup size
            // For pad screens use dynamic size
            presentationType = .dynamic(center: .center)
        }

        let presentr = Presentr(presentationType: presentationType)
        presentr.roundCorners = true
        return presentr
    }()

    func construct(with data: AchievementViewData) -> AchievementPopupViewController {
        let alert = AchievementPopupViewController(nibName: "AchievementPopupViewController", bundle: nil)
        alert.data = data
        return alert
    }
}
