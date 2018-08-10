//
//  ThirdPartiesConfigurator.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityIndicator
import IQKeyboardManagerSwift

final class ThirdPartiesConfigurator {
    func configure() {
        NetworkActivityIndicatorManager.shared.isEnabled = true

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
}
