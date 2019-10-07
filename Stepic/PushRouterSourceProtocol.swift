//
//  PushRouterSourceProtocol.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.07.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit

protocol PushRouterSourceProtocol {
    func push(module: UIViewController)
    func replace(by module: UIViewController)
}

protocol PushStackRouterSourceProtocol {
    func push(moduleStack: [UIViewController])
}

extension UIViewController: PushRouterSourceProtocol, PushStackRouterSourceProtocol {
    @objc
    func push(module: UIViewController) {
        self.navigationController?.pushViewController(module, animated: true)
    }

    @objc
    func replace(by module: UIViewController) {
        self.navigationController?.popViewController(animated: false)
        self.push(module: module)
    }

    @objc
    func push(moduleStack: [UIViewController]) {
        for (index, module) in moduleStack.enumerated() {
            self.navigationController?.pushViewController(module, animated: index == moduleStack.count - 1)
        }
    }
}
