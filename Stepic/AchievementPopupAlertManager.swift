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
    private let source: AmplitudeAnalyticsEvents.Achievements.Source

    init(source: AmplitudeAnalyticsEvents.Achievements.Source) {
        self.source = source
    }

    func present(alert: UIViewController, inController controller: UIViewController) {
        if let alert = alert as? AchievementPopupViewController, let data = alert.data {
            AmplitudeAnalyticsEvents.Achievements.popupOpened(
                source: self.source,
                kind: data.kind,
                level: data.completedLevel
            ).send()
        }
        controller.customPresentViewController(
            self.presentr,
            viewController: alert,
            animated: true
        )
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
        alert.source = self.source
        return alert
    }
}
