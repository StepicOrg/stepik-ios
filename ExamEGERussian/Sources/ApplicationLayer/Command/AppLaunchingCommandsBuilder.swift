//
//  AppLaunchingCommandsBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AppLaunchingCommandsBuilder {
    private var window: UIWindow?
    private var assemblyFactory: AssemblyFactory?

    func setKeyWindow(_ window: UIWindow) -> AppLaunchingCommandsBuilder {
        self.window = window
        return self
    }

    func setAssemblyFactory(_ assemblyFactory: AssemblyFactory) -> AppLaunchingCommandsBuilder {
        self.assemblyFactory = assemblyFactory
        return self
    }

    func build() -> [Command] {
        guard let window = window,
              let assemblyFactory = assemblyFactory else {
            fatalError("window & assemblyFactory must be initialized, call appropriate methods before.")
        }

        return [
            ConfigureThirdPartiesCommand(),
            ConfigureKeyWindowCommand(keyWindow: window, assemblyFactory: assemblyFactory),
            InitializeWebViewCommand()
        ]
    }
}
