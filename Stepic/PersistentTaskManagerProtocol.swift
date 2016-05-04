//
//  PersistentTaskManagerProtocol.swift
//  Stepic
//
//  Created by Alexander Karpov on 04.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

protocol PersistentTaskManagerProtocol {
    func recoverTaskWithName(name: String) -> Executable
    func saveTaskWithName(name: String, type: ExecutableTaskType)
}