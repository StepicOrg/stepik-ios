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
    private static let fileUrl = getURL(for: .documentDirectory).appendingPathComponent("knowledge-graph", isDirectory: false)

    func fetchGraph() -> Promise<KnowledgeGraphPlainObject> {
        return Alamofire
            .request(GraphService.url)
            .responseData()
            .then { self.persistData($0.data) }
            .then { self.decodeData($0) }
    }

    func obtainGraph() -> Promise<KnowledgeGraphPlainObject> {
        return getGraphFromCache()
    }

    private func getGraphFromCache() -> Promise<KnowledgeGraphPlainObject> {
        if let data = FileManager.default.contents(atPath: GraphService.fileUrl.path) {
            return decodeData(data)
        }

        return Promise(error: Error.noDataAtPath)
    }

    private func persistData(_ data: Data) -> Promise<Data> {
        let filePath = GraphService.fileUrl.path
        let fileManager = FileManager.default

        do {
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
            }
            fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
        } catch let error {
            return Promise(error: Error.persisting(message: error.localizedDescription))
        }

        return .value(data)
    }

    private func decodeData(_ data: Data) -> Promise<KnowledgeGraphPlainObject> {
        do {
            let decoder = JSONDecoder()
            let knowledgeGraph = try decoder.decode(KnowledgeGraphPlainObject.self, from: data)
            return .value(knowledgeGraph)
        } catch let error {
            return Promise(error: Error.decoding(message: error.localizedDescription))
        }
    }

    /// Returns URL constructed from specified directory
    private static func getURL(for directory: FileManager.SearchPathDirectory) -> URL {
        if let url = FileManager.default.urls(for: directory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }

    enum Error: Swift.Error {
        case noDataAtPath
        case persisting(message: String)
        case decoding(message: String)
    }
}
