//
//  NSError+Make.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 23/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension NSError {
    static let mockCode = 17

    static var mockError: NSError {
        return make(with: "Mock error occured")
    }

    static func make(with message: String) -> NSError {
        return NSError(
            domain: "ExamEGERussianTests",
            code: mockCode,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}
