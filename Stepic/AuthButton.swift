//
//  AuthButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    override var isEnabled: Bool {
        willSet {
            if newValue != isEnabled {
                let currentBackgroundAlpha = backgroundColor?.cgColor.alpha ?? 1.0
                let newBackgroundAlpha = isEnabled ? currentBackgroundAlpha / 2.0 : currentBackgroundAlpha * 2.0
                backgroundColor = backgroundColor?.withAlphaComponent(newBackgroundAlpha)
            }
        }
    }

}
