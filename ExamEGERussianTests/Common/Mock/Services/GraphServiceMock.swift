//
//  GraphServiceMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class GraphServiceMock: BaseServiceMock<KnowledgeGraphPlainObject>, GraphServiceProtocol {
    func fetchGraph() -> Promise<KnowledgeGraphPlainObject> {
        return resultToBeReturned
    }

    func obtainGraph() -> Promise<KnowledgeGraphPlainObject> {
        return resultToBeReturned
    }
}
