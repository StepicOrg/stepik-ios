//
//  RateAppAlertManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 10.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Presentr

class RateAppAlertManager : AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController)  {
        controller.customPresentViewController(presenter, viewController: alert, animated: true, completion: nil)
    }
    
    let presenter: Presentr = {
        let presenter = Presentr(presentationType: .dynamic(center: .center))
        presenter.roundCorners = true
        return presenter
    }()
    
    func construct() -> RateAppViewController {
        let alert = RateAppViewController(nibName: "RateAppViewController", bundle: nil)
        return alert
    }
}
