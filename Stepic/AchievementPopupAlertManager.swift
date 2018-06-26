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
        let presentr = Presentr(presentationType: .dynamic(center: .center))
        presentr.roundCorners = true
        return presentr
    }()

    func construct(with data: AchievementViewData, canShare: Bool = false) -> AchievementPopupViewController {
        let alert = AchievementPopupViewController(nibName: "AchievementPopupViewController", bundle: nil)
        alert.data = data
        alert.canShare = canShare
        return alert
    }
}
