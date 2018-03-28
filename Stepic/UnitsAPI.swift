//
//  UnitsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class UnitsAPI: APIEndpoint {
    override var name: String { return "units" }

    func retrieve(lesson lessonId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<Unit> {
        return Promise { fulfill, reject in
            retrieve(lesson: lessonId, headers: headers, success: { unit in
                fulfill(unit)
            }, error: { err in
                reject(err)
            })
        }
    }

//    func retrieve(lesson lessonId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Unit) -> Void), error errorHandler: @escaping ((UnitRetrieveError) -> Void)) -> Promise<Unit> {
//        return Promise {
//            fulfill, reject in
//        }
//    }

    @discardableResult func retrieve(lesson lessonId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Unit) -> Void), error errorHandler: @escaping ((UnitRetrieveError) -> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)?lesson=\(lessonId)", headers: headers).responseSwiftyJSON({
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
                    print("RETRIEVE units?\(lessonId): error \(e.domain) \(e.code): \(e.localizedDescription)")
                    errorHandler(.connectionError)
                    return
                }

                if response?.statusCode != 200 {
                    print("RETRIEVE units?\(lessonId)): bad response status code \(String(describing: response?.statusCode))")
                    errorHandler(.badStatus)
                    return
                }

                let units = json["units"].arrayValue.map({return Unit(json: $0)})

                guard let unit = units.first else {
                    errorHandler(.noUnits)
                    return
                }

                success(unit)

                return
            }
        )
    }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Unit], refreshMode: RefreshMode, success: @escaping (([Unit]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}

//TODO: Add parameters
enum UnitRetrieveError: Error {
    case connectionError, badStatus, noUnits
}
