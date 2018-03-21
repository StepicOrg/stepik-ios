//
//  AuthorizationView.swift
//  StepikTV
//
//  Created by Anton Kondrashov on 17/12/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AuthorizationView: class {
    func show(alert: AuthorizationAlert)
    func showProfile(for user: User)
    func showNoProfile()
    func showError(message: String)
}
