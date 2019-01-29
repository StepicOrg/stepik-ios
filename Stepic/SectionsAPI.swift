//
//  SectionsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class SectionsAPI: APIEndpoint {
    override var name: String { return "sections" }

    func retrieve(ids: [Int], existing: [Section]) -> Promise<[Section]> {
        return getObjectsByIds(ids: ids, updating: existing, printOutput: false)
    }

    @available(*, deprecated, message: "Legacy: we want to pass existing")
    @discardableResult func retrieve(ids: [Int]) -> Promise<[Section]> {
        if ids.isEmpty {
            return .value([])
        }

        return getObjectsByIds(ids: ids, updating: Section.fetch(ids))
    }

    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Section], refreshMode: RefreshMode, success: @escaping (([Section]) -> Void), error errorHandler: @escaping ((NetworkError) -> Void)) -> Request? {
        return getObjectsByIds(requestString: name, printOutput: false, ids: ids, deleteObjects: existing, refreshMode: refreshMode, success: success, failure: errorHandler)
    }
}
