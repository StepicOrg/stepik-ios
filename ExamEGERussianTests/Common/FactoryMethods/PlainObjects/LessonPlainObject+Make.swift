//
//  LessonPlainObject+Make.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

extension LessonPlainObject {
    static func make() -> LessonPlainObject {
        var steps = [Int]()
        for _ in 0..<10 {
            steps.append(randomNumber())
        }

        return LessonPlainObject(id: randomNumber(), steps: steps, title: "title", slug: "slug", timeToComplete: 100)
    }

    private static func randomNumber() -> Int {
        return Int(arc4random_uniform(UInt32(100))) + 1
    }
}
