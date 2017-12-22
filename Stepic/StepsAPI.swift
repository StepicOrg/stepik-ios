//
//  StepsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class StepsAPI: APIEndpoint {
    override var name: String { return "steps" }

    func retrieve(ids: [Int], existing: [Step], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders) -> Promise<[Step]> {
        return getObjectsByIds(ids: ids, updating: existing, headers: headers, printOutput: false)
    }
}

extension StepsAPI {
    @available(*, deprecated, message: "Legacy method with callbacks")
    @discardableResult func retrieve(ids: [Int], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, existing: [Step], refreshMode: RefreshMode, success: @escaping (([Step]) -> Void), error errorHandler: @escaping ((RetrieveError) -> Void)) -> Request? {
        retrieve(ids: ids, existing: existing, headers: headers).then { success($0) }.catch { errorHandler(RetrieveError(error: error)) }
        return nil
    }
}
