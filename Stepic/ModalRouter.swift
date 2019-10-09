//
//  ModalRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

final class ModalRouter: RouterProtocol {
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
        self.source.present(module: self.destination, embedInNavigation: self.embedInNavigation)
    }
}
