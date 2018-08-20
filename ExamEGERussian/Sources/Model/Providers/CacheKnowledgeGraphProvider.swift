//
//  CacheKnowledgeGraphProvider.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class CacheKnowledgeGraphProvider: KnowledgeGraphProviderProtocol {
    var knowledgeGraph: KnowledgeGraph {
        return obtainKnowledgeGraph()
    }

    private let graphService: GraphServiceProtocol

    init(graphService: GraphServiceProtocol) {
        self.graphService = graphService
    }

    private func obtainKnowledgeGraph() -> KnowledgeGraph {
        if let plainObject = graphService.obtainGraph().value {
            let builder = KnowledgeGraphBuilder(graphPlainObject: plainObject)
            guard let graph = builder.build() as? KnowledgeGraph else {
                return KnowledgeGraph()
            }

            return graph
        }

        return KnowledgeGraph()
    }
}
