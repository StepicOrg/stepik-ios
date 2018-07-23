//
//  GraphServiceImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

final class GraphServiceImpl: GraphService {
    private static let url = URL(string: "https://www.dropbox.com/s/l8n1wny8qu0gbqt/example.json?dl=1")!

    func obtainGraph() -> Promise<KnowledgeGraphPlainObject> {
        return Alamofire
            .request(GraphServiceImpl.url)
            .responseDecodable(KnowledgeGraphPlainObject.self)
    }
}
