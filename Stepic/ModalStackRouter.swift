//
//  ModalStackRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class ModalStackRouter: RouterProtocol {
    var destinationStack: [UIViewController]
    var source: ModalStackRouterSourceProtocol
    let modalPresentationStyle: UIModalPresentationStyle

    init(
        source: ModalStackRouterSourceProtocol,
        destinationStack: [UIViewController],
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen
    ) {
        self.destinationStack = destinationStack
        self.source = source
        self.modalPresentationStyle = modalPresentationStyle
    }

    func route() {
        self.source.present(moduleStack: self.destinationStack, modalPresentationStyle: self.modalPresentationStyle)
    }
}
