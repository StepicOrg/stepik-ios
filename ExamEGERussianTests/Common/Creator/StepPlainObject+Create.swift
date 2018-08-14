//
//  StepPlainObject+Create.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 14/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

extension StepPlainObject {
    private static let allTypes: [StepPlainObject.StepType] = [
        .text, .choice, .string, .number, .freeAnswer, .math, .sorting, .matching, .fillBlanks,
        .code, .sql, .table, .video, .dataset, .admin
    ]

    static func create(type: StepPlainObject.StepType? = nil) -> StepPlainObject {
        let stepType = type == nil
            ? StepPlainObject.allTypes.randomElement()!
            : type!

        return StepPlainObject(
            id: randomNumber(),
            lessonId: randomNumber(),
            position: randomNumber(),
            text: "Some text goes here",
            type: stepType,
            progressId: nil,
            isPassed: false
        )
    }

    private static func randomNumber() -> Int {
        return Int.random(in: 1...100)
    }
}
