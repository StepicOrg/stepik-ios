//
//  ModalRouterSourceProtocol.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

protocol ModalRouterSourceProtocol {
    func present(module: UIViewController, embedInNavigation: Bool)
}

protocol ModalStackRouterSourceProtocol {
    func present(moduleStack: [UIViewController])
}

extension UIViewController: ModalRouterSourceProtocol, ModalStackRouterSourceProtocol {
    @objc
    func present(module: UIViewController, embedInNavigation: Bool = false) {
        self.present(
            embedInNavigation ? getEmbedded(moduleStack: [module]) : module,
            animated: true
        )
    }

    @objc
    func present(moduleStack: [UIViewController]) {
        let moduleToPresent = getEmbedded(moduleStack: moduleStack)
        self.present(moduleToPresent, animated: true, completion: nil)
    }

    private func getEmbedded(moduleStack: [UIViewController]) -> UIViewController {
        let navigation = StyledNavigationController()
        navigation.setViewControllers(moduleStack, animated: false)
        let closeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: nil)
        closeItem.actionClosure = {
            navigation.dismiss(animated: true, completion: nil)
        }
        moduleStack.last?.navigationItem.leftBarButtonItem = closeItem
        return navigation
    }
}
