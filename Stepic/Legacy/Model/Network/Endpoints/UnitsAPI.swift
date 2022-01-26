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
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol

    override var name: String { "units" }

    init(
        unitsPersistenceService: UnitsPersistenceServiceProtocol = UnitsPersistenceService(),
        timeoutIntervalForRequest: TimeInterval = APIDefaults.Configuration.defaultTimeoutIntervalForRequest
    ) {
        self.unitsPersistenceService = unitsPersistenceService
        super.init(timeoutIntervalForRequest: timeoutIntervalForRequest)
    }

    //TODO: Seems like a bug. Fix this when fixing CoreData duplicates
    func retrieve(lesson lessonId: Int) -> Promise<Unit> {
        let params: Parameters = ["lesson": lessonId]

        return Promise { seal in
            self.retrieve.request(
                requestEndpoint: self.name,
                paramName: self.name,
                params: params,
                updatingObjects: [Unit](),
                withManager: self.manager
            ).done { units, _, _ in
                if let unit = units.first {
                    seal.fulfill(unit)
                } else {
                    seal.reject(UnitRetrieveError.noUnits)
                }
            }.catch { error in
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

        return self.unitsPersistenceService.fetch(ids: ids).then { cachedUnits in
            self.getObjectsByIds(ids: ids, updating: cachedUnits)
        }
    }

    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Unit],
        refreshMode: RefreshMode,
        success: @escaping ([Unit]) -> Void,
        error errorHandler: @escaping (NetworkError) -> Void
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
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        success: @escaping (Unit) -> Void,
        error errorHandler: @escaping (Error) -> Void
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
