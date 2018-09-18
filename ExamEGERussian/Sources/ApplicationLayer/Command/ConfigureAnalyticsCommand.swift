//
//  ConfigureAnalyticsCommand.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/09/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Amplitude_iOS

struct ConfigureAnalyticsCommand: Command {
    func execute() {
        Amplitude.instance().initializeApiKey(Tokens.shared.amplitudeToken)
    }
}
