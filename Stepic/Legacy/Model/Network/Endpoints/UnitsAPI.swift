//
//  UnitsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class UnitsAPI: APIEndpoint {
    override var name: String { "units" }

    //TODO: Seems like a bug. Fix this when fixing CoreData duplicates
    func retrieve(lesson lessonId: Int) -> Promise<Unit> {
        let params: Parameters = ["lesson": lessonId]
        return Promise { seal in
            retrieve.request(requestEndpoint: "units", paramName: "units", params: params, updatingObjects: [Unit](), withManager: manager).done {
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
        }
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult
    func retrieve(ids: [Int]) -> Promise<[Unit]> {
        if ids.isEmpty {
            return .value([])
        }

        return getObjectsByIds(ids: ids, updating: Unit.fetch(ids))
    }

    @discardableResult
    func retrieve(
        ids: [Int],
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        existing: [Unit],
        refreshMode: RefreshMode,
        success: @escaping (([Unit]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.getObjectsByIds(
            requestString: self.name,
            printOutput: false,
            ids: ids,
            deleteObjects: existing,
            refreshMode: refreshMode,
            success: success,
            failure: errorHandler
        )
    }
}

extension UnitsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult
    func retrieve(
        lesson lessonId: Int,
        headers: [String: String] = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping ((Unit) -> Void),
        error errorHandler: @escaping ((Error) -> Void)
    ) -> Request? {
        self.retrieve(lesson: lessonId).done { unit in
            success(unit)
        }.catch { error in
            errorHandler(error)
        }
        return nil
    }
}

enum UnitRetrieveError: Error {
    case noUnits
}