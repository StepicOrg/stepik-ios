//
//  GraphService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 18/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

final class GraphService: GraphServiceProtocol {
    private static let url = URL(string: "https://www.dropbox.com/s/l8n1wny8qu0gbqt/example.json?dl=1")!
    private static let fileName = "plain-object-response"

    private let fileStorage: FileStorage

    init(fileStorage: FileStorage) {
        self.fileStorage = fileStorage
    }

    func fetchGraph() -> Promise<KnowledgeGraphPlainObject> {
        return Alamofire
            .request(GraphService.url)
            .responseData()
            .then { self.persistData($0.data) }
            .then { self.decodeData($0) }
    }

    func obtainGraph() -> Promise<KnowledgeGraphPlainObject> {
        return obtainFromCache()
    }

    private func obtainFromCache() -> Promise<KnowledgeGraphPlainObject> {
        if let data = fileStorage.loadData(fileName: GraphService.fileName) {
            return decodeData(data)
        }

        return Promise(error: GraphServiceError.noDataAtPath)
    }

    private func persistData(_ data: Data) -> Promise<Data> {
        return Promise { seal in
            self.fileStorage.persist(data: data, named: GraphService.fileName) { (_, error) in
                seal.resolve(data, error)
            }
        }
    }

    private func decodeData(_ data: Data) -> Promise<KnowledgeGraphPlainObject> {
        do {
            let knowledgeGraph = try JSONDecoder().decode(KnowledgeGraphPlainObject.self, from: data)
            return .value(knowledgeGraph)
        } catch let error {
            return Promise(error: GraphServiceError.unableToDecode(message: error.localizedDescription))
        }
    }

    enum GraphServiceError: Error {
        case noDataAtPath
        case unableToPersist(message: String)
        case unableToDecode(message: String)
    }
}
