//
//  StepsServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class StepsServiceMock: StepsService, PromiseReturnable {
    var resultToBeReturned: Promise<[StepPlainObject]> = Promise(error: NSError.mockError)

    func fetchSteps(with ids: [Int]) -> Promise<[StepPlainObject]> {
        return resultToBeReturned
    }

    func fetchProgresses(stepsIds ids: [Int]) -> Promise<[StepPlainObject]> {
        return resultToBeReturned
    }

    func markAsSolved(stepsIds ids: [Int]) -> Promise<[StepPlainObject]> {
        return resultToBeReturned
    }

    func obtainSteps(with ids: [Int]) -> Promise<[StepPlainObject]> {
        return resultToBeReturned
    }
}
