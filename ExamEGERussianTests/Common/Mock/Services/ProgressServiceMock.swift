//
//  ProgressServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class ProgressServiceMock: BaseServiceMock<[ExamEGERussian.Progress]>, ProgressService {
    func fetchProgresses(with ids: [String], refreshMode: RefreshMode) -> Promise<[ExamEGERussian.Progress]> {
        return resultToBeReturned
    }

    func obtainProgresses(with ids: [String]) -> Promise<[ExamEGERussian.Progress]> {
        return resultToBeReturned
    }
}
