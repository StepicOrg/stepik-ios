//
//  QueriesAPI.swift
//  Stepic
//
//  Created by Ostrenkiy on 01.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

//TODO: Refactor this by adding class Query: JSONSerializable
class QueriesAPI: APIEndpoint {
    override var name: String { return "queries" }

    func retrieve(query: String) -> Promise<[String]> {
        let params: Parameters = ["query": query]
        return Promise { seal in
            retrieve.request(requestEndpoint: "queries", paramName: "queries", params: params, updatingObjects: Array<Query>(), withManager: manager).done {
                queries, _ in
                seal.fulfill(queries.map {$0.text})
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }

    @discardableResult func retrieve(query: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (([String]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {

        retrieve(query: query).done {
            queries in
            success(queries)
        }.catch {
            error in
            guard let e = error as? NetworkError else {
                errorHandler(NetworkError.other(error))
                return
            }
            errorHandler(e)
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
