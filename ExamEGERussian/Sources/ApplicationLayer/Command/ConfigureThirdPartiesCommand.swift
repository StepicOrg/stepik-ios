//
//  ConfigureThirdPartiesCommand.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityIndicator
import IQKeyboardManagerSwift
import SVProgressHUD

struct ConfigureThirdPartiesCommand: Command {
    func execute() {
        NetworkActivityIndicatorManager.shared.isEnabled = true

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setHapticsEnabled(true)
    }
}
