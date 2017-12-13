//
//  StreaksStepikAlertManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

/*
 AlertManager class for streaks alert
 */
class StreaksStepikAlertManager: AlertManager, StreaksAlertPresentationDelegate {
    func present(alert: UIViewController, inController controller: UIViewController) {
        controller.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
//        controller.present(alert, animated: true, completion: nil)
    }

    var presentationManager: StreaksAlertPresentationManager?

    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .dynamic(center: .center))
        presenter.roundCorners = true
        return presenter
    }()

    func construct(presentationManager: StreaksAlertPresentationManager) -> StreakAlertViewController {
        self.presentationManager = presentationManager
        presentationManager.delegate = self
        let alert = StreakAlertViewController(nibName: "StreakAlertViewController", bundle: nil)
        alert.yesAction = {
            [weak self] in
            self?.presentationManager?.notifyPressed(fromPreferences: false)
        }
        alert.noAction = {
            [weak self] in
            self?.presentationManager = nil
        }
        return alert
    }

    func didDismiss() {
        self.presentationManager = nil
    }
}
