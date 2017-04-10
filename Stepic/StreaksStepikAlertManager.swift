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
class StreaksStepikAlertManager : AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController) {
        controller.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
//        controller.present(alert, animated: true, completion: nil)
    }
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .popup)
        return presenter
    }()
    
    func construct(notify notifyHandler : @escaping (Void)->Void) -> StreakAlertViewController {
        let alert = StreakAlertViewController(nibName: "StreakAlertViewController", bundle: nil)
        alert.yesAction = notifyHandler
        return alert
    }
}
