//
//  SectionsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class SectionsAPI: APIEndpoint {
    override class var name: String { "sections" }

    func retrieve(ids: [Int], existing: [Section]) -> Promise<[Section]> {
        self.getObjectsByIds(ids: ids, updating: existing, printOutput: false)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult
    func retrieve(ids: [Int]) -> Promise<[Section]> {
        if ids.isEmpty {
            return .value([])
        }

        return self.getObjectsByIds(ids: ids, updating: Section.fetch(ids))
    }

    @discardableResult
    func retrieve(
        ids: [Int],
        headers: HTTPHeaders = AuthInfo.shared.initialHTTPHeaders,
        existing: [Section],
        refreshMode: RefreshMode,
        success: @escaping (([Section]) -> Void),
        error errorHandler: @escaping ((NetworkError) -> Void)
    ) -> Request? {
        self.getObjectsByIds(
            requestString: Self.name,
            printOutput: false,
            ids: ids,
            deleteObjects: existing,
            refreshMode: refreshMode,
            success: success,
            failure: errorHandler
        )
    }
}
