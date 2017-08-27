//
//  AlertManagerProtocol.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.11.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Protocol for all AlertManager classes.
 Defines the presentation pattern
 */
protocol AlertManager {
    func present(alert: UIViewController, inController controller: UIViewController)
}
