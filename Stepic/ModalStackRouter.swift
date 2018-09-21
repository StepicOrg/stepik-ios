//
//  ModalStackRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class ModalStackRouter: RouterProtocol {
    var destinationStack: [UIViewController]
    var source: ModalStackRouterSourceProtocol

    init(
        source: ModalStackRouterSourceProtocol,
        destinationStack: [UIViewController]
    ) {
        self.destinationStack = destinationStack
        self.source = source
    }

    func route() {
        source.present(moduleStack: destinationStack)
    }

}
