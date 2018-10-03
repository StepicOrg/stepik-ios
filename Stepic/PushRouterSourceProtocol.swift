//
//  PushRouterSourceProtocol.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.07.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

protocol PushRouterSourceProtocol {
    func push(module: UIViewController)
}

protocol PushStackRouterSourceProtocol {
    func push(moduleStack: [UIViewController])
}

extension UIViewController: PushRouterSourceProtocol, PushStackRouterSourceProtocol {
    @objc
    func push(module: UIViewController) {
        navigationController?.pushViewController(module, animated: true)
    }

    @objc
    func push(moduleStack: [UIViewController]) {
        for (index, module) in moduleStack.enumerated() {
            navigationController?.pushViewController(module, animated: index == moduleStack.count - 1)
        }
    }
}
