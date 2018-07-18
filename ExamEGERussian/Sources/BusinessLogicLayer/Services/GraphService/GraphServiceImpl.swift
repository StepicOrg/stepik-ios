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
    private enum Error: Swift.Error {
        case badURLResponse
        case notFound
        case clientError(Int)
        case serverError(Int)
        case unexpectedError(Int)
    }

    func obtainGraph(_ completionHandler: @escaping (StepicResult<AbstractGraph<String>>) -> Void) {
        firstly {
            URLSession.shared.dataTask(.promise, with: url)
        }.then { data, response -> Promise<KnowledgeGraphPlainObject> in
            guard let httpResponse = response as? HTTPURLResponse else { throw Error.badURLResponse }
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200...299:
                return self.decodeData(data)
            case 404:
                throw Error.notFound
            case 400...499:
                throw Error.clientError(statusCode)
            case 500...599:
                throw Error.serverError(statusCode)
            default:
                throw Error.unexpectedError(statusCode)
            }
        }.done { decodedModel in
            print(decodedModel)
        }.catch { error in
            completionHandler(.failure(error))
        }
    }

    private func decodeData(_ data: Data) -> Promise<KnowledgeGraphPlainObject> {
        return Promise { seal in
            let jsonDecoder = JSONDecoder()
            let responseModel = try jsonDecoder.decode(KnowledgeGraphPlainObject.self, from: data)
            seal.fulfill(responseModel)
        }
    }
}
