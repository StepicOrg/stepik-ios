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

class CongratulationAlertManager: AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController)  {
        controller.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
    }
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.backgroundOpacity = 0.0
        presenter.dismissOnTap = false
        presenter.dismissAnimated = true
        presenter.dismissTransitionType = TransitionType.custom(CrossDissolveAnimation(options: .normal(duration: 0.4)))
        presenter.roundCorners = true
        presenter.cornerRadius = 10
        return presenter
    }()
    
    func construct(title: String? = "", congratulationText: String? = "", continueHandler: (() -> ())? = nil) -> AlertViewController {
        let controller = Presentr.alertViewController(title: title ?? "", body: congratulationText ?? "")
        let continueAction = AlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default) {
            continueHandler?()
        }
        controller.addAction(continueAction)
        return controller
    }
}
