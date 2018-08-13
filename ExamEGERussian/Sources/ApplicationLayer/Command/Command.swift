//
//  Command.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

// https://sourcemaking.com/design_patterns/command
/// Encapsulates a command request as an object.
protocol Command {
    func execute()
}
