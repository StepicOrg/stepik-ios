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
    let modalPresentationStyle: UIModalPresentationStyle

    init(
        source: ModalRouterSourceProtocol,
        destination: UIViewController,
        embedInNavigation: Bool = false,
        modalPresentationStyle: UIModalPresentationStyle = .fullScreen
    ) {
        self.destination = destination
        self.source = source
        self.embedInNavigation = embedInNavigation
        self.modalPresentationStyle = modalPresentationStyle
    }

    func route() {
        self.source.present(
            module: self.destination,
            embedInNavigation: self.embedInNavigation,
            modalPresentationStyle: self.modalPresentationStyle
        )
    }
}
