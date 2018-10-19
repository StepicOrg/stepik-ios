//
//  EnvironmentVariable.swift
//  Stepic
//
//  Created by Ivan Magda on 19/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum EnvironmentVariable {
    static let isStepikApiDebugLogEnabled = getStepikApiDebugLogEnvironmentVariable()

    private static func getStepikApiDebugLogEnvironmentVariable() -> Bool {
        let value = environmentVariable(named: "STEPIK_API_DEBUG_LOG_ENABLED") ?? EnvironmentValue.yes.rawValue
        return value == EnvironmentValue.yes.rawValue ? true : false
    }

    private static func environmentVariable(named: String) -> String? {
        let processInfo = ProcessInfo.processInfo

        guard let value = processInfo.environment[named] else {
            print("‼️ Missing Environment Variable: '\(named)'")
            return nil
        }

        return value
    }

    private enum EnvironmentValue: String {
        case yes = "YES"
        case no = "NO"
    }
}
