//
//  StreaksAlertManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 AlertManager class for streaks alert
 */
class StreaksAlertManager: AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController) {
        controller.present(alert, animated: true, completion: nil)
    }

    func construct(notify notifyHandler : @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "Streaks", message: "Notify about streaks? This option can be changed in preferences.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Notify", style: .default, handler: {
            _ in
            notifyHandler()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
}
