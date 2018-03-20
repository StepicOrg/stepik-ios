//
//  LessonsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class LessonsAPI: APIEndpoint {
    override var name: String { return "lessons" }

    func retrieve(ids: [Int], existing: [Lesson], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Lesson]> {
        return getObjectsByIds(ids: ids, updating: existing, printOutput: false)
    }
}

extension LessonsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Lesson], refreshMode: RefreshMode, success: @escaping (([Lesson]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        retrieve(ids: ids, existing: existing, headers: headers).then { success($0) }.catch { errorHandler(RetrieveError(error: $0)) }
        return nil
    }
}
