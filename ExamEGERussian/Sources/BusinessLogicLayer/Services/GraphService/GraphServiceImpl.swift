//
//  GraphServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

private let url = URL(string: "https://www.dropbox.com/s/l8n1wny8qu0gbqt/example.json?dl=1")!

final class GraphServiceImpl: GraphService {
    func obtainGraph(_ completionHandler: @escaping (StepicResult<KnowledgeGraphPlainObject>) -> Void) {
        firstly {
            URLSession.shared.dataTask(.promise, with: url).validate()
        }.map {
            try JSONDecoder().decode(KnowledgeGraphPlainObject.self, from: $0.data)
        }.done {
            completionHandler(.success($0))
        }.catch {
            completionHandler(.failure($0))
        }
    }
}
