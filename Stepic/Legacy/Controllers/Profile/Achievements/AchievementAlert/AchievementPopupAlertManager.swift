//
//  AchievementPopupAlertManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

final class AchievementPopupAlertManager: AlertManager {
    private let source: AchievementPopupViewController.Source
    private let analytics: Analytics

    init(source: AchievementPopupViewController.Source, analytics: Analytics = StepikAnalytics.shared) {
        self.source = source
        self.analytics = analytics
    }

    func present(alert: UIViewController, inController controller: UIViewController) {
        if let achievementPopupViewController = alert as? AchievementPopupViewController,
           let data = achievementPopupViewController.data {
            self.analytics.send(
                .achievementsPopupOpened(source: self.source.rawValue, kind: data.id, level: data.completedLevel)
            )
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
