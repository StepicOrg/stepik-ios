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

    //TODO: Seems like a bug. Fix this when fixing CoreData duplicates
    func retrieve(lesson lessonId: Int) -> Promise<Unit> {
        let params: Parameters = ["lesson": lessonId]
        return Promise { seal in
            retrieve.request(requestEndpoint: "units", paramName: "units", params: params, updatingObjects: Array<Unit>(), withManager: manager).done {
                units, _, _ in
                guard let unit: Unit = units.first else {
                    seal.reject(UnitRetrieveError.noUnits)
                    return
                }
                seal.fulfill(unit)
            }.catch {
                error in
                seal.reject(error)
            }
//            This is a correct replacement after CoreData duplicates fix for this
//            retrieve.requestWithFetching(requestEndpoint: "units", paramName: "units", params: params, withManager: manager).then {
//                (units, _) -> Void in
//                guard let unit: Unit = units.first else {
//                    reject(UnitRetrieveError.noUnits)
//                    return
//                }
//                fulfill(unit)
//            }.catch {
//                error in
//                reject(error)
//            }
        }
    }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Unit], refreshMode: RefreshMode, success: @escaping (([Unit]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}

extension UnitsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(lesson lessonId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Unit) -> Void), error errorHandler: @escaping ((Error) -> Void)) -> Request? {
        retrieve(lesson: lessonId).done {
            unit in
            success(unit)
            }.catch {
                error in
                errorHandler(error)
        }
        return nil
    }
}

enum UnitRetrieveError: Error {
    case noUnits
}
