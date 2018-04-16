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

    @discardableResult func retrieve(query: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping (([String]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {

        let params: Parameters = ["query": query]

        return AlamofireDefaultSessionManager.shared.request("\(StepicApplicationsInfo.apiURL)/\(name)", parameters: params, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error as NSError? {
                print("RETRIEVE \(self.name)/\(query): error \(e.domain) \(e.code): \(e.localizedDescription)")
                if e.code == -999 {
                    errorHandler(.cancelled)
                    return
                } else {
                    errorHandler(.connectionError)
                    return
                }
            }

            if response?.statusCode != 200 {
                print("RETRIEVE \(self.name)/\(query): bad response status code \(String(describing: response?.statusCode))")
                errorHandler(.badStatus)
                return
            }

            let queries = json["queries"].arrayValue.flatMap {
                $0["text"].string
            }

            success(queries)

            return
        })
    }

}
