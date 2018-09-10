//
//  KnowledgeGraphProviderMock.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 21/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
@testable import ExamEGERussian

final class KnowledgeGraphProviderMock: KnowledgeGraphProviderProtocol {
    let knowledgeGraph: KnowledgeGraph

    init(knowledgeGraph: KnowledgeGraph = KnowledgeGraph()) {
        self.knowledgeGraph = knowledgeGraph
    }
}
