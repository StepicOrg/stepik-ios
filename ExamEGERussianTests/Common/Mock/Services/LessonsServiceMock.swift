//
//  LessonsServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class LessonsServiceMock: LessonsService, PromiseReturnable {
    var resultToBeReturned: Promise<[LessonPlainObject]> = Promise(error: NSError.mockError)

    func fetchLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return resultToBeReturned
    }

    func obtainLessons(with ids: [Int]) -> Promise<[LessonPlainObject]> {
        return resultToBeReturned
    }
}
