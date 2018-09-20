//
//  ThirdPartiesConfigurator.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/09/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityIndicator
import IQKeyboardManagerSwift
import SVProgressHUD
import Amplitude_iOS

final class ThirdPartiesConfigurator {
    func configure() {
        NetworkActivityIndicatorManager.shared.isEnabled = true

        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 24
        IQKeyboardManager.sharedManager().enableAutoToolbar = false

        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumDismissTimeInterval(0.5)
        SVProgressHUD.setHapticsEnabled(true)

        Amplitude.instance().initializeApiKey(Tokens.shared.amplitudeToken)
    }
}
