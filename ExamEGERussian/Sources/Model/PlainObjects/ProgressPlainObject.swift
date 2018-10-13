//
//  ProgressPlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 08/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct ProgressPlainObject {
    let id: String
    let isPassed: Bool
    let lastViewed: Double
    let score: Int
    let numberOfSteps: Int
    let numberOfStepsPassed: Int
    let cost: Int

    var percentPassed: Float {
        return numberOfSteps != 0
            ? Float(numberOfStepsPassed) / Float(numberOfSteps) * 100
            : 100.0
    }
}

extension ProgressPlainObject {
    init(_ progress: Progress) {
        self.id = progress.id
        self.isPassed = progress.isPassed
        self.lastViewed = progress.lastViewed
        self.score = progress.score
        self.numberOfSteps = progress.numberOfSteps
        self.numberOfStepsPassed = progress.numberOfStepsPassed
        self.cost = progress.score
    }
}
