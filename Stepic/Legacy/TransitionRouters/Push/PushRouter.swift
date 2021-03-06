//
//  PushRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.07.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit

final class PushRouter: RouterProtocol {
    var destination: UIViewController
    var source: PushRouterSourceProtocol

    init(
        source: PushRouterSourceProtocol,
        destination: UIViewController
    ) {
        self.destination = destination
        self.source = source
    }

    func route() {
        self.source.push(module: self.destination)
    }
}
