//
//  CongratulationAlertManager.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 18.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

extension Alerts {
    static let congratulation = CongratulationAlertManager()
}

typealias CongratulationType = CongratulationViewController.CongratulationType

class CongratulationAlertManager: AlertManager {

    func present(alert: UIViewController, inController controller: UIViewController) {
        presenter.customBackgroundView = CongratsView(frame: controller.view.bounds)
        controller.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
    }

    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .dynamic(center: .center))
        presenter.backgroundOpacity = 0.0
        presenter.dismissOnTap = false
        presenter.dismissAnimated = true
        presenter.dismissTransitionType = TransitionType.custom(CrossDissolveAnimation(options: .normal(duration: 0.4)))
        presenter.roundCorners = true
        presenter.cornerRadius = 10
        presenter.dropShadow = PresentrShadow(shadowColor: .black, shadowOpacity: 0.3, shadowOffset: CGSize(width: 0.0, height: 0.0), shadowRadius: 1.2)
        return presenter
    }()

    func construct(congratulationType: CongratulationType, continueHandler: (() -> Void)? = nil) -> CongratulationViewController {
        let controller = CongratulationViewController(nibName: "CongratulationViewController", bundle: nil)
        controller.continueHandler = continueHandler
        controller.congratulationType = congratulationType
        return controller
    }
}
