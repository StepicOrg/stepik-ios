//
//  Result.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum StepicResult<Value, Error: Swift.Error> {
    case success(Value)
    case error(Error)

    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .error:
            return false
        }
    }

    public var isError: Bool {
        return !isSuccess
    }

    public var value: Value? {
        switch self {
        case .success(let value):
            return value
        case .error:
            return nil
        }
    }

    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .error(let error):
            return error
        }
    }
}
