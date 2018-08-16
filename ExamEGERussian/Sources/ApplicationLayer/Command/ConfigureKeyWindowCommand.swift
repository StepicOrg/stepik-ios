//
//  ConfigureKeyWindowCommand.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UIWindow

struct ConfigureKeyWindowCommand: Command {
    let keyWindow: UIWindow
    let assemblyFactory: AssemblyFactory

    func execute() {
        guard let router = assemblyFactory.applicationAssembly.module().router else {
            fatalError("Could not instantiate router")
        }

        router.start(keyWindow)
    }
}
