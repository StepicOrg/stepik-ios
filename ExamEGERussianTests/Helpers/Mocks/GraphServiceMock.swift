//
//  GraphServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
@testable import ExamEGERussian

final class GraphServiceMock: GraphService {
    enum Error: Swift.Error {
        case mockError
    }

    var resultToBeReturned: StepicResult<KnowledgeGraphPlainObject>! = .failure(Error.mockError)

    func obtainGraph(_ completionHandler: @escaping GraphService.Handler) {
        completionHandler(resultToBeReturned)
    }
}
