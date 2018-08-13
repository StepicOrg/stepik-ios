//
//  AppLaunchingCommandsBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UIWindow

final class AppLaunchingCommandsBuilder {
    private var window: UIWindow!
    private lazy var assemblyFactory: AssemblyFactory = {
        AssemblyFactoryBuilder()
            .setServiceFactory(ServiceFactoryBuilder().build())
            .build()
    }()

    func setKeyWindow(_ window: UIWindow) -> AppLaunchingCommandsBuilder {
        self.window = window
        return self
    }

    func build() -> [Command] {
        return [
            ConfigureThirdPartiesCommand(),
            ConfigureKeyWindowCommand(keyWindow: window, assemblyFactory: assemblyFactory)
        ]
    }
}
