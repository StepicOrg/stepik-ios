//
//  AppLaunchingCommandsBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AppLaunchingCommandsBuilder {
    func build() -> [Command] {
        return [
            ConfigureThirdPartiesCommand(),
            InitializeWebViewCommand()
        ]
    }
}
