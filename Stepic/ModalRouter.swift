//
//  ModalRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

class ModalRouter: RouterProtocol {
    var destination: UIViewController
    var source: ModalRouterSourceProtocol
    var embedInNavigation: Bool

    init(
        source: ModalRouterSourceProtocol,
        destination: UIViewController,
        embedInNavigation: Bool = false
    ) {
        self.destination = destination
        self.source = source
        self.embedInNavigation = embedInNavigation
    }

    func route() {
        source.present(module: destination, embedInNavigation: embedInNavigation)
    }
}
