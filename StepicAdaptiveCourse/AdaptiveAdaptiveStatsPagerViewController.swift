//
//  AdaptiveAdaptiveStatsPagerViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class AdaptiveAdaptiveStatsPagerViewController: AdaptiveStatsPagerViewController {
    override var sections: [AdaptiveStatsSection] {
        return [.progress, .achievements, .rating]
    }

    var achievementsManager: AchievementManager?

    @IBAction func onCancelButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func controllerForSection(_ section: AdaptiveStatsSection) -> UIViewController {
        guard let achievementsManager = self.achievementsManager else {
            return UIViewController()
        }

        if section == .achievements {
            let vc = ControllerHelper.instantiateViewController(identifier: "Achievements", storyboardName: "AdaptiveMain") as! AdaptiveAchievementsViewController
            vc.presenter = AdaptiveAchievementsPresenter(achievementsManager: achievementsManager, view: vc)
            return vc
        } else {
            return super.controllerForSection(section)
        }
    }
}
