//
//  QueriesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 01.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

//TODO: Refactor this by adding class Query: JSONSerializable
final class QueriesAPI: APIEndpoint {
    override var name: String { "queries" }

    func retrieve(query: String) -> Promise<[String]> {
        let params: Parameters = ["query": query]
        return Promise { seal in
            self.retrieve.request(
                requestEndpoint: "queries",
                paramName: "queries",
                params: params,
                updatingObjects: [Query](),
                withManager: manager
            ).done { queries, _ in
                seal.fulfill(queries.map { $0.text })
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    @discardableResult
    func retrieve(
        query: String,
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (([String]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.retrieve(query: query).done { queries in
            success(queries)
        }.catch { error in
            guard let networkError = error as? NetworkError else {
                errorHandler(NetworkError.other(error))
                return
            }
            errorHandler(networkError)
        }

        return nil
    }
}

class Query: JSONSerializable {
    var id: Int = 0
    var text: String

    required init(json: JSON) {
        self.text = json["text"].stringValue
    }

    func update(json: JSON) {
        self.text = json["text"].stringValue
    }
}
