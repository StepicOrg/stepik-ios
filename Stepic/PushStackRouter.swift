//
//  PushStackRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class PushStackRouter: RouterProtocol {
    var destinationStack: [UIViewController]
    var source: PushStackRouterSourceProtocol

    init(
        source: PushStackRouterSourceProtocol,
        destinationStack: [UIViewController]
    ) {
        self.destinationStack = destinationStack
        self.source = source
    }

    func route() {
        self.source.push(moduleStack: destinationStack)
    }
}
